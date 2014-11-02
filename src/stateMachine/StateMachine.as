package stateMachine
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import stateMachine.event.TransitionCompleteEvent;
	import stateMachine.event.TransitionDeniedEvent;
	
	public class StateMachine implements IStateMachine, IEventDispatcher
	{
		//----------------------------------
		//  CONSTS
		//----------------------------------
		public static const UNINITIALIZED_STATE:String = "uninitializedState";
		
		public static const UNKNOWN_STATE:IState = new State("unknown.state");
		public static const UNKNOWN_PARENT_STATE:IState = new State("unknown.parent.state");
		public static const NO_PARENT_STATE:IState = new State("no.parent.state");
		
		//----------------------------------
		//  vars
		//----------------------------------
		/* @private */
		private var _dispatcher:IEventDispatcher;
		/* @private */
		private var _nameToStates:Dictionary;
		/* @private */
		private var _state:String = UNINITIALIZED_STATE;
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		public function init():void {
			_nameToStates = new Dictionary();
			_dispatcher = new EventDispatcher();
		}
		
		public function destroy():void {
			for (var key:String in _nameToStates) {
				_nameToStates[key] = null;
				delete _nameToStates[key];
			}
			_nameToStates = null;
			_dispatcher = null;
		}
		
		public function setDispatcher(dispatcher:IEventDispatcher):void {
			_dispatcher = dispatcher;
		}
		
		//----------------------------------
		//  IStateMachine
		//----------------------------------
		/**
		 * Adds a new state
		 * @param stateName	The name of the new State
		 * @param stateData	A hash containing state enter and exit callbacks and allowed states to transition from
		 * The "from" property can be a string or and array with the state names or * to allow any transition
		 **/
		public function addState(newState:IState):void {
			//if (newState.name in _nameToStates) {
			//trace("[StateMachine] Overriding existing state " + newState.name);
			//}
			_nameToStates[newState.name] = newState;
		}
		
		/**
		 * Sets the first state, calls enter callback and dispatches TRANSITION_COMPLETE
		 * These will only occour if no state is defined
		 * @param stateName	The name of the State
		 **/
		public function set initialState(stateName:String):void {
			if (_state == UNINITIALIZED_STATE && stateName in _nameToStates) {
				_state = stateName;
				executeEnterCallbacksForTree(stateName, null);
				
				var outEvent:TransitionCompleteEvent = TransitionCompleteEvent.transitionComplete(stateName, null);
				dispatchEvent(outEvent);
			}
		}
		
		/**
		 *	Getters for the current state and for the Dictionary of states
		 */
		public function get state():String {
			return _state;
		}
		
		public function hasStateByName(name:String):Boolean {
			return (_nameToStates[name] != undefined);
		}
		
		/**
		 * Verifies if a transition can be made from the current state to the
		 * state passed as param
		 * 
		 * @param stateName	The name of the State
		 **/
		public function canChangeStateTo(toState:String):Boolean {
			return (hasStateByName(toState)
				&& toState != _state
				&& allowTransitionFrom(_state, toState)
			);
		}
		
		/**
		 * Changes the current state
		 * This will only be done if the intended state allows the transition from the current state
		 * Changing states will call the exit callback for the exiting state and enter callback for the entering state
		 * @param stateTo	The name of the state to transition to
		 **/
		public function changeState(stateTo:String):void {
			// If there is no state that maches stateTo
			if (!hasStateByName(stateTo)) {
				//trace("[StateMachine] Cannot make transition: State " + stateTo + " is not defined");
				return;
			}
			
			// If current state is not allowed to make this transition
			if (!canChangeStateTo(stateTo)) {
				//trace("[StateMachine] Transition to " + stateTo + " from " + state + " denied");
				var outEvent:TransitionDeniedEvent = TransitionDeniedEvent.transitionDenied(_state, stateTo, IState(_nameToStates[stateTo]).from);
				_dispatcher.dispatchEvent(outEvent);
				return;
			}
			
			// call exit and enter callbacks (if they exits)
			var path:Array = findPath(_state, stateTo);
			if(path[0] > 0) { // hasFroms
				getStateByName(_state).onExit.exit(_state, stateTo, _state);
				var parentState:IState = getStateByName(_state);
				for (var i:int = 0; i < path[0] - 1; i++) {
					parentState = getParentStateByName(parentState.name); // parentState.parent;
					if (parentState.onExit != null) {
						parentState.onExit.exit(_state, stateTo, parentState.name);
					}
				}
			}
			
			var oldState:String = _state;
			_state = stateTo;
			if (path[1] > 0) { // hasTos
				executeEnterCallbacksForTree(stateTo, oldState);
			}
			//trace("[StateMachine] State Changed to " + _state);
			
			// Transition is complete. dispatch TRANSITION_COMPLETE
			var completeEvent:TransitionCompleteEvent = TransitionCompleteEvent.transitionComplete(stateTo, oldState);
			dispatchEvent(completeEvent);
		}
		
		//----------------------------------
		//  IEventDispatcher
		//----------------------------------
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return _dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}
		
		//--------------------------------------------------------------------------
		//
		//  INTERNAL METHODS
		//
		//--------------------------------------------------------------------------
		internal function allowTransitionFrom(fromState:String, toState:String):Boolean {
			var fromStateAllNames:Array = getAllStateNames(fromState);
			var toStateFroms:Array = getAllFromsForStateByName(toState);
			return (toStateFroms.indexOf(State.WILDCARD) >= 0 
				|| doTransitionsMatch(fromStateAllNames, toStateFroms));
		}
		
		/**
		 * Discovers the how many "exits" and how many "enters" are there between two
		 * given states and returns an array with these two integers
		 * @param stateFrom The state to exit
		 * @param stateTo The state to enter
		 **/
		internal function findPath(stateFrom:String, stateTo:String):Array {
			// Verifies if the states are in the same "branch" or have a common parent
			var froms:int = 0;
			var tos:int = 0;
			if(hasStateByName(stateFrom) && hasStateByName(stateTo)) {
				var fromState:IState = getStateByName(stateFrom);
				while (fromState && fromState != UNKNOWN_STATE && fromState != UNKNOWN_PARENT_STATE) {
					tos = 0;
					var toState:IState = getStateByName(stateTo);
					while (toState && toState != UNKNOWN_STATE && toState != UNKNOWN_PARENT_STATE) {
						if (fromState == toState) {
							// They are in the same brach or have
							// a common parent Common parent
							return [froms, tos];
						}
						tos++;
						toState = getParentStateByName(toState.name); //toState.parent;
					}
					froms++;
					fromState = getParentStateByName(fromState.name) //fromState.parent;
				}
			}
			
			// No direct path, no commom parent: exit until root then enter until element
			return [froms, tos];
		}
		
		internal function getParentStateByName(name:String):IState {
			if (!hasStateByName(name)) {
				return UNKNOWN_STATE;
			} else {
				var stateName:IState = getStateByName(name);
				var parentName:String = stateName.parentName;
				if (parentName == State.NO_PARENT) {
					return NO_PARENT_STATE; 
				} else if(!hasStateByName(parentName)) {
					return UNKNOWN_PARENT_STATE;
				} else {
					return getStateByName(parentName);					
				}
			}
		}
		
		internal function getStateByName(name:String):IState {
			return hasStateByName(name) ? _nameToStates[name] : UNKNOWN_STATE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------
		private function executeEnterCallbacksForTree(stateTo:String, oldState:String):void {
			var parentStates:Array = getAllStatesChildToRootByName(stateTo);
			var n:int = parentStates.length;
			for (var j:int = n - 1; j >= 0; j--) {
				var state:IState = parentStates[j];
				state.onEnter.enter(stateTo, oldState, state.name);
			}
		}
		
		private function getAllStatesChildToRootByName(name:String):Array {
			var states:Array = [];
			while (hasStateByName(name)) {
				var state:IState = getStateByName(name);
				states.push(state);
				if(state.parentName == State.NO_PARENT) {
					break;
				}
				name = state.parentName;
			}
			return states;
		}
		
		private function doTransitionsMatch(fromStateAllNames:Array, toStateFroms:Array):Boolean {
			for each (var name:String in fromStateAllNames) {
				if(toStateFroms.indexOf(name) < 0) {
					continue;
				}
				return true;
			}
			return false;
		}
		
		private function getAllStateNames(stateName:String):Array {
			var names:Array = [];
			var states:Array = getAllStatesChildToRootByName(stateName);
			for each (var state:IState in states) {
				names.push(state.name);
			}
			return names;
		}
		
		private function getAllFromsForStateByName(toState:String):Array {
			var froms:Array = [];
			var states:Array = getAllStatesChildToRootByName(toState);
			for each (var state:IState in states) {
				for each(var fromName:String in state.from) {
					if(froms.indexOf(fromName) < 0) {
						froms.push(fromName);
					}
				}
			}
			return froms;
		}
	}
}