package stateMachine.event
{
	import flash.events.Event;
	
	/**
	 * TransitionDeniedEvent.as
	 * Description:
	 * ...
	 * 
	 * @author hclark
	 * Copyright ©2014 _Company_ All rights reserved.
	 **/
	public class TransitionDeniedEvent extends Event
	{
		//----------------------------------
		//  Type
		//----------------------------------
		public static const TRANSITION_DENIED:String = "te.transitionDenied";
		public static function transitionDenied(fromState:String, toState:String, allowedStates:Object):TransitionDeniedEvent {
			var event:TransitionDeniedEvent = new TransitionDeniedEvent(TRANSITION_DENIED);
			event.fromState = fromState;
			event.toState = toState;
			event.allowedStates = allowedStates;
			return event;
		}
		
		//----------------------------------
		//  Payload
		//----------------------------------
		public var fromState:String;
		public var toState:String;
		public var allowedStates:Object;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function TransitionDeniedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}	
	}
}