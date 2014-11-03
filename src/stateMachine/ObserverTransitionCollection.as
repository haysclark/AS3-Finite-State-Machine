package stateMachine
{
	/**
	 * A Collection class for IObserverTransitions which parrots
	 * messages to subscribrers.
	 * 
	 * See Observer Pattern (GOF)
	 */
	public class ObserverTransitionCollection implements IObserverTransition
	{
		//----------------------------------
		//  vars
		//----------------------------------
		private var _observerTransitions:Array; // of IObserverTransitions
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		public function init():void {
			_observerTransitions = [];
		}
		
		public function destroy():void {
			while(_observerTransitions.length) {
				unsubscribe(_observerTransitions.pop() as IObserverTransition);
			}
			_observerTransitions = null;
		}
		
		public function subscribe(observer:IObserverTransition):void {
			_observerTransitions.push(observer);
		}
		
		public function unsubscribe(observer:IObserverTransition):void {
			var n:int = _observerTransitions.length;
			for(var i:int = 0; i < n; i++) {
				if(observer !== _observerTransitions[i]) {
					continue;
				}
				_observerTransitions.splice(i, 1);
			}
		}
		
		//----------------------------------
		//  IObserverTransition
		//----------------------------------
		public function transitionComplete(toState:String, fromState:String):void {
			var n:int = _observerTransitions.length;
			for(var i:int = 0; i < n; i++) {
				var observer:IObserverTransition = _observerTransitions[i] as IObserverTransition;
				observer..transitionComplete(toState, fromState)
			}
		}
		
		public function transitionDenied(toState:String, fromState:String, allowedFromStates:Array):void {
			var n:int = _observerTransitions.length;
			for(var i:int = 0; i < n; i++) {
				var observer:IObserverTransition = _observerTransitions[i] as IObserverTransition;
				observer.transitionDenied(toState, fromState, allowedFromStates)
			}
		}
	}	
}