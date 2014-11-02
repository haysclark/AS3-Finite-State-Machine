package stateMachine.event
{
	import flash.events.Event;
	
	/**
	 * TransitionCompleteEvent.as
	 * Description:
	 * ...
	 * 
	 * @author hclark
	 * Copyright ©2014 _Company_ All rights reserved.
	 **/
	public class TransitionCompleteEvent extends Event
	{
		//----------------------------------
		//  Type
		//----------------------------------
		public static const TRANSITION_COMPLETE:String = "te:transitionComplete";
		public static function transitionComplete(toState:String, fromState:String):TransitionCompleteEvent {
			var event:TransitionCompleteEvent = new TransitionCompleteEvent(TRANSITION_COMPLETE);
			event.toState = toState;
			event.fromState = fromState;
			return event;
		}
		
		//----------------------------------
		//  Payload
		//----------------------------------
		public var toState:String;
		public var fromState:String;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function TransitionCompleteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}