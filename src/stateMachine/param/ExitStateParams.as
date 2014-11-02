package stateMachine.param
{
	import flash.events.Event;
	
	/**
	 * ExitStatePrams.as
	 * Description:
	 * ...
	 * 
	 * @author hclark
	 * Copyright ©2014 _Company_ All rights reserved.
	 **/
	public class ExitStateParams extends Event
	{
		//----------------------------------
		//  Type
		//----------------------------------
		public static const EXIT_CALLBACK:String = "esp.exitCallback";
		public static function exitCallback(fromState:String, toState:String, currentState:String = null):ExitStateParams {
			var event:ExitStateParams = new ExitStateParams(EXIT_CALLBACK);
			event.toState = toState;
			event.fromState = fromState;
			event.currentState = currentState;
			return event;	
		}
		
		//----------------------------------
		//  Payload
		//----------------------------------
		public var fromState:String;
		public var toState:String;
		public var currentState:String;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function ExitStateParams(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}