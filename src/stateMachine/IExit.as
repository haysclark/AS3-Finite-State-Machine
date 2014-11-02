package stateMachine
{
	import stateMachine.param.ExitStateParams;

	public interface IExit
	{
		function exit(params:ExitStateParams):void;
	}
}