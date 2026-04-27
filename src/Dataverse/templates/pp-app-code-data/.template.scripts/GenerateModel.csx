#!/usr/bin/env dotnet-script
// Usage: dotnet script GenerateModel.csx -- <SolutionPath> <EntityLogicalName> [OutputPath]
// Example: dotnet script GenerateModel.csx -- "C:\...\Solutions.DataModel" "udpp_warehouseitem" "C:\...\models"

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Linq;

// ── Args ──────────────────────────────────────────────────────────────────────
if (Args.Count < 2)
{
    Console.Error.WriteLine("Usage: dotnet script GenerateModel.csx -- <SolutionPath> <EntityLogicalName> [OutputPath]");
    return;
}

var solutionPath = Args[0];
var entityLogicalName = Args[1];
var outputPath = Args.Count > 2 ? Args[2] : Directory.GetCurrentDirectory();

// ── Locate Entity.xml ─────────────────────────────────────────────────────────
var entityXmlPath = Path.Combine(solutionPath, "SolutionDeclarationsRoot", "Entities", entityLogicalName, "Entity.xml");
if (!File.Exists(entityXmlPath))
{
    Console.Error.WriteLine($"Entity.xml not found at: {entityXmlPath}");
    return;
}

var doc = XDocument.Load(entityXmlPath);
var entityNode = doc.Root.Element("EntityInfo").Element("entity");

// ── EntitySetName (plural, used as TS prefix) ────────────────────────────────
var entitySetName = entityNode.Element("EntitySetName").Value; // e.g. udpp_warehouseitems
var tsPrefix = char.ToUpper(entitySetName[0]) + entitySetName.Substring(1); // e.g. Udpp_warehouseitems

// ── Primary key ───────────────────────────────────────────────────────────────
string primaryKeyName = null;

// ── Parse attributes ──────────────────────────────────────────────────────────
var attributes = new List<AttrInfo>();

foreach (var attr in entityNode.Element("attributes").Elements("attribute"))
{
    var info = new AttrInfo
    {
        PhysicalName = attr.Attribute("PhysicalName")?.Value ?? "",
        LogicalName = attr.Element("LogicalName")?.Value ?? attr.Element("Name")?.Value ?? "",
        Type = attr.Element("Type")?.Value ?? "",
        RequiredLevel = attr.Element("RequiredLevel")?.Value ?? "none",
        ValidForCreateApi = attr.Element("ValidForCreateApi")?.Value == "1",
        ValidForUpdateApi = attr.Element("ValidForUpdateApi")?.Value == "1",
        ValidForReadApi = attr.Element("ValidForReadApi")?.Value == "1",
        IsCustomField = attr.Element("IsCustomField")?.Value == "1",
        IsLogical = attr.Element("IsLogical")?.Value == "1",
        HasDisplayMask = !string.IsNullOrEmpty(attr.Element("DisplayMask")?.Value),
    };

    // Parse inline option set (state / status / picklist)
    var optionsetEl = attr.Element("optionset");
    if (optionsetEl != null)
    {
        info.Options = new Dictionary<int, string>();
        // state type
        foreach (var state in optionsetEl.Descendants("state"))
        {
            var val = int.Parse(state.Attribute("value").Value);
            var label = state.Descendants("label").FirstOrDefault()?.Attribute("description")?.Value ?? "";
            info.Options[val] = label;
        }
        // status type
        foreach (var status in optionsetEl.Descendants("status"))
        {
            var val = int.Parse(status.Attribute("value").Value);
            var label = status.Descendants("label").FirstOrDefault()?.Attribute("description")?.Value ?? "";
            info.Options[val] = label;
        }
        // picklist options
        foreach (var opt in optionsetEl.Elements("options").Elements("option"))
        {
            var val = int.Parse(opt.Attribute("value").Value);
            var label = opt.Descendants("label").FirstOrDefault()?.Attribute("description")?.Value ?? "";
            info.Options[val] = label;
        }
    }

    // Global option set reference
    var optionSetNameEl = attr.Element("OptionSetName");
    if (optionSetNameEl != null && !string.IsNullOrEmpty(optionSetNameEl.Value))
    {
        info.GlobalOptionSetName = optionSetNameEl.Value;
        // Load global option set
        var globalPath = Path.Combine(solutionPath, "SolutionDeclarationsRoot", "OptionSets", info.GlobalOptionSetName + ".xml");
        if (File.Exists(globalPath))
        {
            var globalDoc = XDocument.Load(globalPath);
            info.Options = new Dictionary<int, string>();
            foreach (var opt in globalDoc.Root.Elements("options").Elements("option"))
            {
                var val = int.Parse(opt.Attribute("value").Value);
                var label = opt.Descendants("label").FirstOrDefault()?.Attribute("description")?.Value ?? "";
                info.Options[val] = label;
            }
        }
    }

    if (info.Type == "primarykey")
        primaryKeyName = info.LogicalName;

    attributes.Add(info);
}

// ── Detect custom lookups and load relationship info ──────────────────────────
var customLookups = attributes.Where(a => a.Type == "lookup" && a.IsCustomField).ToList();

// ── Build output ──────────────────────────────────────────────────────────────
var sb = new StringBuilder();
sb.AppendLine("/*!");
sb.AppendLine(" * Copyright (C) Microsoft Corporation. All rights reserved.");
sb.AppendLine(" * This file is autogenerated. Do not edit this file directly.");
sb.AppendLine(" */");

// ── Option set constants ──────────────────────────────────────────────────────
// Collect option set attributes: state, status, picklist
var optionSetAttrs = attributes
    .Where(a => (a.Type == "state" || a.Type == "status" || a.Type == "picklist") && a.Options != null && a.Options.Count > 0)
    .OrderBy(a => GetOptionSetOrder(a.Type))
    .ThenBy(a => a.LogicalName)
    .ToList();

foreach (var attr in optionSetAttrs)
{
    var typeName = tsPrefix + attr.LogicalName;
    sb.AppendLine($"export const {typeName} = {{");
    foreach (var kvp in attr.Options.OrderBy(o => o.Key))
    {
        bool isLast = kvp.Key == attr.Options.OrderBy(o => o.Key).Last().Key;
        sb.AppendLine($"  {kvp.Key}: '{kvp.Value}'" + (isLast ? "" : ","));
    }
    sb.AppendLine("} as const;");
    sb.AppendLine($"export type {typeName} = keyof typeof {typeName};");
}

// ── Base interface ────────────────────────────────────────────────────────────
// Fields: ValidForCreateApi=1 OR ValidForUpdateApi=1 OR primarykey
var baseFields = new List<BaseField>();

foreach (var attr in attributes)
{
    bool inBase = attr.ValidForCreateApi || attr.ValidForUpdateApi || attr.Type == "primarykey";
    if (!inBase) continue;

    bool isRequired = attr.RequiredLevel == "required" || attr.RequiredLevel == "systemrequired";
    string optional = isRequired ? "" : "?";

    if (attr.Type == "state" || attr.Type == "status" || attr.Type == "picklist")
    {
        var typeName = tsPrefix + attr.LogicalName;
        baseFields.Add(new BaseField { Name = attr.LogicalName, TypeStr = typeName, Optional = optional });
    }
    else if (attr.Type == "lookup" && attr.IsCustomField)
    {
        // Custom lookups use @odata.bind in Base
        baseFields.Add(new BaseField
        {
            Name = $"\"{attr.LogicalName}@odata.bind\"",
            SortKey = attr.LogicalName + "@odata.bind",
            TypeStr = "string",
            Optional = optional
        });
    }
    else if (attr.Type == "owner")
    {
        // Owner adds ownerid + owneridtype
        baseFields.Add(new BaseField { Name = attr.LogicalName, TypeStr = "string", Optional = optional });
        baseFields.Add(new BaseField { Name = attr.LogicalName + "type", TypeStr = "string", Optional = optional });
    }
    else
    {
        baseFields.Add(new BaseField { Name = attr.LogicalName, TypeStr = "string", Optional = optional });
    }
}

baseFields = baseFields.OrderBy(f => f.SortKey ?? f.Name).ToList();

sb.AppendLine();
sb.AppendLine($"export interface {tsPrefix}Base {{");
foreach (var f in baseFields)
{
    sb.AppendLine($"  {f.Name}{f.Optional}: {f.TypeStr};");
}
sb.AppendLine("}");

// ── Extended interface ────────────────────────────────────────────────────────
sb.AppendLine();
sb.AppendLine($"export interface {tsPrefix} extends {tsPrefix}Base {{");

// Part 1: string properties (names, yominames, dates, optionset names, versionnumber)
var stringProps = new List<ExtField>();

// System lookups that are read-only
var systemUserLookups = new HashSet<string> { "createdby", "createdonbehalfby", "modifiedby", "modifiedonbehalfby" };

foreach (var attr in attributes)
{
    if (attr.Type == "primarykey") continue;

    // Read-only lookups (system, non-logical, with DisplayMask)
    if ((attr.Type == "lookup" || attr.Type == "owner") && !attr.IsCustomField && !attr.IsLogical)
    {
        if (attr.Type == "owner" || (attr.HasDisplayMask))
        {
            // {name}name
            bool nameRequired = attr.Type == "owner" || attr.LogicalName == "owningbusinessunit";
            stringProps.Add(new ExtField { Name = attr.LogicalName + "name", TypeStr = "string", Optional = nameRequired ? "" : "?" });

            // yominame for user-related lookups and owner
            if (systemUserLookups.Contains(attr.LogicalName) || attr.Type == "owner")
            {
                stringProps.Add(new ExtField { Name = attr.LogicalName + "yominame", TypeStr = "string", Optional = "" });
            }
        }
    }

    // Custom lookups: {name}name in extended
    if (attr.Type == "lookup" && attr.IsCustomField)
    {
        stringProps.Add(new ExtField { Name = attr.LogicalName + "name", TypeStr = "string", Optional = "?" });
    }

    // Read-only datetimes
    if (attr.Type == "datetime" && !attr.ValidForCreateApi && !attr.ValidForUpdateApi)
    {
        stringProps.Add(new ExtField { Name = attr.LogicalName, TypeStr = "string", Optional = "?" });
    }

    // Option set name fields
    if (attr.Type == "state" || attr.Type == "status" || attr.Type == "picklist")
    {
        stringProps.Add(new ExtField { Name = attr.LogicalName + "name", TypeStr = "string", Optional = "?" });
    }
}

// versionnumber always present
stringProps.Add(new ExtField { Name = "versionnumber", TypeStr = "string", Optional = "?" });

stringProps = stringProps.OrderBy(f => f.Name).ToList();
foreach (var f in stringProps)
{
    sb.AppendLine($"  {f.Name}{f.Optional}: {f.TypeStr};");
}

// Part 2: lookup object + _value pairs
var lookupPairs = new List<string>();
foreach (var attr in attributes)
{
    if ((attr.Type == "lookup" || attr.Type == "owner") && !attr.IsCustomField && attr.Type != "owner")
    {
        // System lookups (not owner)
        lookupPairs.Add(attr.LogicalName);
    }
    if (attr.Type == "lookup" && attr.IsCustomField)
    {
        lookupPairs.Add(attr.LogicalName);
    }
}

// ownerid does NOT get object pair — owningteam/owninguser do
lookupPairs = lookupPairs.OrderBy(n => n).ToList();
foreach (var name in lookupPairs)
{
    sb.AppendLine($"  {name}?: object;");
    sb.AppendLine($"  _{name}_value?: string;");
}

sb.AppendLine("}");

// ── Write output file ─────────────────────────────────────────────────────────
var outputFileName = $"{tsPrefix}Model.ts";
var outputFilePath = Path.Combine(outputPath, outputFileName);
var result = sb.ToString().Replace("\r\n", "\n").TrimEnd('\n');
File.WriteAllText(outputFilePath, result);
Console.WriteLine($"Generated: {outputFilePath}");

// ── Helper types ──────────────────────────────────────────────────────────────
int GetOptionSetOrder(string type)
{
    return type switch { "state" => 0, "status" => 1, _ => 2 };
}

class AttrInfo
{
    public string PhysicalName;
    public string LogicalName;
    public string Type;
    public string RequiredLevel;
    public bool ValidForCreateApi;
    public bool ValidForUpdateApi;
    public bool ValidForReadApi;
    public bool IsCustomField;
    public bool IsLogical;
    public bool HasDisplayMask;
    public Dictionary<int, string> Options;
    public string GlobalOptionSetName;
}

class BaseField
{
    public string Name;
    public string SortKey;
    public string TypeStr;
    public string Optional;
}

class ExtField
{
    public string Name;
    public string TypeStr;
    public string Optional;
}
