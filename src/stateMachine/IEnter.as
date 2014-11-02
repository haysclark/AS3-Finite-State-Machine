package stateMachine
{
	public interface IEnter
	{
		function enter(toState:String, fromState:String, currentState:String):void;
	}
}