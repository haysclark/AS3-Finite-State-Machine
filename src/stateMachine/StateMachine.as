package stateMachine
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class StateMachine implements IEventDispatcher
	{
		//----------------------------------
		//  CONSTS
		//----------------------------------
		public static const NO_STATE:String = "no state";
		public static const UNKNOWN_STATE:IState = new UnknownState("unknown.state");
		
		//----------------------------------
		//  vars
		//----------------------------------
		public var name:String
		
		/* @private */
		public var parentState:IState;
		/* @private */
		public var parentStates:Array;
		/* @private */
		private var _path:Array;
		/* @private */
		private var _state:String = NO_STATE;
		/* @private */
		private var _states:Dictionary;
		
		//
		private var _dispatcher:IEventDispatcher;
		
		/**
		 * Creates a generic StateMachine. Available states can be set with addState and initial state can
		 * be set using initialState setter.
		 * @example This sample creates a state machine for a player model with 3 states (Playing, paused and stopped)
		 * <pre>
		 *	playerSM = new StateMachine();
		 *
		 *	playerSM.addState("playing",{ enter: onPlayingEnter, exit: onPlayingExit, from:["paused","stopped"] });
		 *	playerSM.addState("paused",{ enter: onPausedEnter, from:"playing"});
		 *	playerSM.addState("stopped",{ enter: onStoppedEnter, from:"*"});
		 *	
		 *	playerSM.addEventListener(StateMachineEvent.TRANSITION_DENIED,transitionDeniedFunction);
		 *	playerSM.addEventListener(StateMachineEvent.TRANSITION_COMPLETE,transitionCompleteFunction);
		 *	
		 *	playerSM.initialState = "stopped";
		 * </pre> 
		 *
		 * It's also possible to create hierarchical state machines using the argument "parent" in the addState method
		 * @example This example shows the creation of a hierarchical state machine for the monster of a game
		 * (Its a simplified version of the state machine used to control the AI in the original Quake game)
		 *	<pre>
		 *	monsterSM = new StateMachine()
		 *	
		 *	monsterSM.addState("idle",{enter:onIdle, from:"attack"})
		 *	monsterSM.addState("attack",{enter:onAttack, from:"idle"})
		 *	monsterSM.addState("melee attack",{parent:"atack", enter:onMeleeAttack, from:"attack"})
		 *	monsterSM.addState("smash",{parent:"melle attack", enter:onSmash})
		 *	monsterSM.addState("punch",{parent:"melle attack", enter:onPunch})
		 *	monsterSM.addState("missle attack",{parent:"attack", enter:onMissle})
		 *	monsterSM.addState("die",{enter:onDead, from:"attack", enter:onDie})
		 *	
		 *	monsterSM.initialState = "idle"
		 *	</pre>
		 */
		public function StateMachine() {
			_states = new Dictionary();
			_dispatcher = new EventDispatcher();
		}
		
		/**
		 * Adds a new state
		 * @param stateName	The name of the new State
		 * @param stateData	A hash containing state enter and exit callbacks and allowed states to transition from
		 * The "from" property can be a string or and array with the state names or * to allow any transition
		 **/
		public function addState(newState:IState):void {
			if (newState.name in _states) {
				trace("[StateMachine]", name, "Overriding existing state " + newState.name);
				//Todo(Hays) Looks like we need to undo init stuff?
			}
			
			_states[newState.name] = newState;
			//Todo(Hays) remove
			// newState.init(this); // setsup parent mapping
		}
		
		/**
		 * Sets the first state, calls enter callback and dispatches TRANSITION_COMPLETE
		 * These will only occour if no state is defined
		 * @param stateName	The name of the State
		 **/
		public function set initialState(stateName:String):void {
			if (_state == NO_STATE && stateName in _states) {
				_state = stateName;
				
				var callbackEvent:StateMachineEvent = StateMachineEvent.enterCallback(stateName);
				
				//Todo(Hays) Not under test
				// Some Root state logic?
				/**
				if (getStateByName(_state).root) {
					parentStates = getStateByName(_state).parents
					for (var i:int = getStateByName(_state).parents.length - 1; i >= 0; i--) {
						//if (parentStates[i].enter) {
							callbackEvent.currentState = parentStates[i].name
							IState(parentStates[i]).enter.enter(callbackEvent)
						//}
					}
				}
				 **/
				//Todo(Hays) End Not under test
				
				// Call state enter handler, no null check required due to null pattern
				callbackEvent.currentState = _state;
				
				// Todo: this logic can be likely handled when you change the currentState.
				getStateByName(_state).enter.enter(callbackEvent);
				
				// dispatch Transition Complete
				var outEvent:StateMachineEvent = StateMachineEvent.transitionComplete(stateName);
				dispatchEvent(outEvent);
			}
		}
		
		/**
		 *	Getters for the current state and for the Dictionary of states
		 */
		public function get state():String {
			//return _states[_state];
			return _state;
		}
		
		public function hasStateByName(name:String):Boolean {
			return (_states[name] != undefined);
		}
		
		/**
		 * Todo(Hays) this breaks encapsulation, idealy
		 * we should not be exposing this data.
		 */
		public function getStateByName(name:String):IState {
			return hasStateByName(name) ? _states[name] : UNKNOWN_STATE;
		}
		
		
		private function getRootStateByName(stateName:String):IState {
			if(!hasStateByName(stateName)) {
				return UNKNOWN_STATE;
			}
			
			var state:IState = getStateByName(stateName);
			return state;
			//return state.root;
		}
		
		/**
		 * Verifies if a transition can be made from the current state to the
		 * state passed as param
		 * 
		 * @param stateName	The name of the State
		 **/
		public function canChangeStateTo(stateName:String):Boolean {
			return (hasStateByName(stateName)
				&& stateName != _state
				&& getStateByName(stateName)
					.allowTransitionFrom(getRootStateByName(_state).name)
			);
		}
		
		/**
		 * Discovers the how many "exits" and how many "enters" are there between two
		 * given states and returns an array with these two integers
		 * @param stateFrom The state to exit
		 * @param stateTo The state to enter
		 **/
		public function findPath(stateFrom:String, stateTo:String):Array {
			// Verifies if the states are in the same "branch" or have a common parent
			var fromState:IState = getStateByName(stateFrom);
			var froms:int = 0;
			var tos:int = 0;
			if(hasStateByName(stateFrom) 
				&& hasStateByName(stateTo)) {
				while (fromState) {
					tos = 0;
					var toState:IState = getStateByName(stateTo);
					while (toState) {
						if (fromState == toState) {
							// They are in the same brach or have
							// a common parent Common parent
							return [froms, tos];
						}
						tos++;
						toState = getParentByName(toState.name); //toState.parent;
					}
					froms++;
					fromState = getParentByName(fromState.name) //fromState.parent;
				}
			}
			
			// No direct path, no commom parent: exit until root then enter until element
			return [froms, tos];
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
				trace("[StateMachine]", name, "Cannot make transition: State " + stateTo + " is not defined");
				return;
			}
			
			// If current state is not allowed to make this transition
			if (!canChangeStateTo(stateTo)) {
				trace("[StateMachine]", name, "Transition to " + stateTo + " from " + state + " denied");
				var outEvent:StateMachineEvent = StateMachineEvent.transitionDenied(_state, stateTo, IState(_states[stateTo]).from);
				_dispatcher.dispatchEvent(outEvent);
				return;
			}
			
			// call exit and enter callbacks (if they exits)
			_path = findPath(_state, stateTo);
			if(_path[0] > 0) { // hasFroms
				var exitCallbackEvent:StateMachineEvent = StateMachineEvent.exitCallback(_state, stateTo, _state);
				//if (getStateByName(_state).exit) { // no longer needed because of null pattern
					//exitCallbackEvent.currentState = _state;
					//_states[_state].exit.call(null, _exitCallbackEvent);
					getStateByName(_state).exit.exit(exitCallbackEvent);
				//}
				
				parentState = getStateByName(_state);
				for (var i:int = 0; i < _path[0] - 1; i++) {
					parentState = getParentByName(parentState.name); // parentState.parent;
					if (parentState.exit != null) {
						exitCallbackEvent.currentState = parentState.name;
						//parentState.exit.call(null, _exitCallbackEvent);
						parentState.exit.exit(exitCallbackEvent);
					}
				}
			}
			
			var oldState:String = _state;
			_state = stateTo;
			if (_path[1] > 0) { // hasTos
				var enterCallbackEvent:StateMachineEvent = new StateMachineEvent(StateMachineEvent.ENTER_CALLBACK);
				enterCallbackEvent.toState = stateTo;
				enterCallbackEvent.fromState = oldState;
				
				/**
				if (getStateByName(stateTo).root) {
					parentStates = getStateByName(stateTo).parents
					for (var k:int = _path[1] - 2; k >= 0; k--) {
						if (parentStates[k] && parentStates[k].enter) {
							enterCallbackEvent.currentState = parentStates[k].name;
							//parentStates[k].enter.call(null, _enterCallbackEvent);
							IState(parentStates[k]).enter.enter(enterCallbackEvent);
						}
					}
				}
				**/
				
				if (getStateByName(_state).enter) {
					enterCallbackEvent.currentState = _state;
					//_states[_state].enter.call(null, _enterCallbackEvent);
					getStateByName(_state).enter.enter(enterCallbackEvent);
				}
			}
			trace("[StateMachine]", name, "State Changed to " + _state);
			
			// Transition is complete. dispatch TRANSITION_COMPLETE
			outEvent = new StateMachineEvent(StateMachineEvent.TRANSITION_COMPLETE);
			outEvent.fromState = oldState ;
			outEvent.toState = stateTo;
			dispatchEvent(outEvent);
		}
		
		public function setDispatcher(dispatcher:IEventDispatcher):void {
			_dispatcher = dispatcher;
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
		//seems dangerous, accessed by States...
		internal function get states():Dictionary {
			return _states;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------
		private function getParentByName(name:String):IState {
			// TODO Auto Generated method stub
			return null;
		}
	}
}