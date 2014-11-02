package stateMachine.param
{
	import flash.events.Event;
	
	/**
	 * EnterStateParams.as
	 * Description:
	 * ...
	 * 
	 * @author hclark
	 * Copyright ©2014 _Company_ All rights reserved.
	 **/
	public class EnterStateParams extends Event
	{
		//----------------------------------
		//  Type
		//----------------------------------
		public static const ENTER_CALLBACK:String = "esp.enterCallback";
		public static function enterCallback(toState:String, fromState:String = null, currentState:String = null):EnterStateParams {
			var event:EnterStateParams = new EnterStateParams(ENTER_CALLBACK);
			event.toState = toState;
			event.fromState = fromState;
			event.currentState = currentState;
			return event;
		}
		
		//----------------------------------
		//  Payload
		//----------------------------------
		public var toState:String;
		public var fromState:String;
		public var currentState:String;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function EnterStateParams(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}