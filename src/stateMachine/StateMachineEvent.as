package stateMachine
{
	import flash.events.Event;
	
	public class StateMachineEvent extends Event
	{
		//----------------------------------
		//  Type
		//----------------------------------
		public static const EXIT_CALLBACK:String = "exit";
		public static function exitCallback(fromState:String, toState:String, currentState:String):StateMachineEvent {
			var event:StateMachineEvent = new StateMachineEvent(EXIT_CALLBACK);
			event.fromState = fromState;
			event.toState = toState;
			event.currentState = currentState;
			return event;	
		}
		
		public static const ENTER_CALLBACK:String = "enter";
		public static function enterCallback(stateName:String):StateMachineEvent {
			var event:StateMachineEvent = new StateMachineEvent(ENTER_CALLBACK);
			event.toState = stateName;
			return event;
		}
		
		public static const TRANSITION_DENIED:String = "transition denied";
		public static function transitionDenied(fromState:String, toState:String, allowedStates:Object):StateMachineEvent {
			var event:StateMachineEvent = new StateMachineEvent(ENTER_CALLBACK);
			event.fromState = fromState;
			event.toState = toState;
			event.allowedStates = allowedStates;
			return event;
		}
		
		public static const TRANSITION_COMPLETE:String = "transition complete";
		public static function transitionComplete(stateName:String):StateMachineEvent{
			var event:StateMachineEvent = new StateMachineEvent(TRANSITION_COMPLETE);
			event.toState = stateName;
			return event;
		}
		
		//----------------------------------
		//  Payload
		//----------------------------------
		public var toState:String;
		public var fromState:String;
		public var currentState:String;
		public var allowedStates:Object;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function StateMachineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}