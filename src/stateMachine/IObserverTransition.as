package stateMachine
{
	/**
	 * Interface for observing state transitions and denials.  Interface provided so
	 * users can choose between Native AS3 Events, as3-signals, etc.
	 */
	public interface IObserverTransition
	{
		function transitionComplete(toState:String, fromState:String):void;
		function transitionDenied(toState:String, fromState:String, allowedFromStates:Array):void;
	}
}