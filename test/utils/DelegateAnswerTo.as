package utils
{
	import org.mockito.api.Answer;
	import org.mockito.api.StubbingContext;
	import org.mockito.api.StubbingContextAware;

	/**
	 * Used for mocking when the parameters being passed into the call need to be inspected
	 * in detail more than the normal matchers for example object property count
	 */
	public class DelegateAnswerTo implements Answer, StubbingContextAware
	{	
		//----------------------------------
		//  vars
		//----------------------------------
		public var callArgs:Array; //Vector.<Array>
		
		/**
		 * Delegates the answer to a given callback. Whenever the stubbed
		 * function is called, the call will be delegated to this callback, and the
		 * original arguments will be passed.
		 */
		private var delegateCallback:Function;
		private var context:StubbingContext;
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		public function DelegateAnswerTo(callback:Function) {
			delegateCallback = callback;
			callArgs = []; //callArgs = new Vector.<Array>();
		}
		
		public function useContext(stubbingContext:StubbingContext):void {
			context = stubbingContext;
		}
		
		public function give():* {
			callArgs.push(context.args);
			return delegateCallback.apply(null, context.args);
		}
	}
}

