package stateMachine
{
	public interface IExit
	{
		function exit(fromState:String, toState:String, currentState:String = null):void;
	}
}