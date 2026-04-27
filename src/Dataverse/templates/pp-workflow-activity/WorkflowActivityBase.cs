using System.Activities;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Workflow;

namespace TALXIS.SDK.Libraries.Plugins.CDS
{
    public abstract class WorkflowActivityBase : CodeActivity
    {
        protected IOrganizationService _organizationService;
        protected IOrganizationService _systemOrganizationService;
        protected CodeActivityContext _executionContext;
        protected IWorkflowContext _context;
        protected ITracingService _tracingService;

        protected sealed override void Execute(CodeActivityContext executionContext)
        {
            _executionContext = executionContext;

            // Get workflow context
            _context = executionContext.GetExtension<IWorkflowContext>();
            var serviceFactory = executionContext.GetExtension<IOrganizationServiceFactory>();
            _organizationService = serviceFactory.CreateOrganizationService(_context.UserId);
            _systemOrganizationService = serviceFactory.CreateOrganizationService(null);
            _tracingService = executionContext.GetExtension<ITracingService>();

            Execute();
        }

        protected virtual void Execute()
        {

        }
    }
}