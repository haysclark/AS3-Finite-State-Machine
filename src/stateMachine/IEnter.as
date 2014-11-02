package stateMachine
{
	import stateMachine.param.EnterStateParams;

	public interface IEnter
	{
		function enter(params:EnterStateParams):void;
	}
}