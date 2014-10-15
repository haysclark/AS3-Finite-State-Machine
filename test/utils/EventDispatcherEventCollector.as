package utils
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.mockito.integrations.any;
	import org.mockito.integrations.given;
	
	import utils.DelegateAnswerTo;
	
	/**
	 * EventDispatcherEventCatcher
	 **/
	public class EventDispatcherEventCollector
	{
		//----------------------------------
		//  Vars
		//----------------------------------
		public var events:Array; //Vector.<Event>;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function EventDispatcherEventCollector(eventDispatcher:IEventDispatcher) {
			events = []; //new Vector.<Event>();
			given(eventDispatcher.dispatchEvent(any()))
				.will(new DelegateAnswerTo(answer));
		}
		
		//--------------------------------------------------------------------------
		//
		//  GETTER/SETTER METHODS
		//
		//--------------------------------------------------------------------------
		public function get timesDispatched():int {
			return events.length;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------
		private function answer(event:Event):void {
			events.push(event);
		}
	}
}