export class Main {
    public static async onLoad(executionContext: Xrm.Events.EventContext): Promise<void> {
        const formContext = executionContext.getFormContext();
        console.log(`${formContext.data.entity.getEntityName()} form loaded.`);
    }
}
