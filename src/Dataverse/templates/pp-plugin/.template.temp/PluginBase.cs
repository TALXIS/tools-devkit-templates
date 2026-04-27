using Microsoft.Xrm.Sdk;
using System;

namespace SolutionLogicalNameExample
{
    /// <summary>
    /// Base implementation for a plug-in. 
    /// </summary>
    public abstract class PluginBase : IPlugin
    {
        protected IPluginExecutionContext _context;
        protected IOrganizationService _organizationService;
        protected ITracingService _tracingService;

        public void Execute(IServiceProvider serviceProvider)
        {
            ITracingService tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            _tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            // Obtain the execution context from the service provider.
            _context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

            // obtain the organization service reference.
            IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            _organizationService = serviceFactory.CreateOrganizationService(_context.UserId);

            OnExecute();
        }

        // method is marked as abstract, all inheriting class must implement it.
        protected abstract void OnExecute();
    }
}
