using System;
using Microsoft.Xrm.Sdk;
using FakeXrmEasy.Abstractions;
using FakeXrmEasy.Abstractions.Enums;
using FakeXrmEasy.Middleware;
using FakeXrmEasy.Middleware.Crud;
using FakeXrmEasy.Middleware.Messages;
using FakeXrmEasy.Abstractions.Plugins;
using FakeXrmEasy.Plugins;

namespace Plugins.Tests
{
    public abstract class FakeXrmEasyTestBase
    {
        protected readonly IXrmFakedContext _context;
        protected readonly IOrganizationService _service;

        protected FakeXrmEasyTestBase()
        {
            _context = MiddlewareBuilder
                .New()
                .AddCrud()
                // .AddFakeMessageExecutors(typeof(FakeXrmEasyTestBase).Assembly)
                .UseCrud()
                .UseMessages()
                // here you choose the license for your scenario
                .SetLicense(FakeXrmEasyLicense.Commercial)
                // or FakeXrmEasyLicense.RPL_1_5 / FakeXrmEasyLicense.NonCommercial
                .Build();

            _service = _context.GetOrganizationService();
        }
    }
}
