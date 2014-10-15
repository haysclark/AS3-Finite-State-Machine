package stateMachine
{
	public class State implements IState
	{
		//----------------------------------
		//  CONSTS
		//----------------------------------
		public static const NO_ENTER:IEnter = new NoopEnter();
		public static const NO_EXIT:IExit = new NoopExit();
		//public static const NO_PARENT:IState = null; // new NoParentState(null);
		
		public static const WILDCARD:String = "*";
		
		//----------------------------------
		//  vars
		//----------------------------------
		private var _name:String;
		private var _from:Object;
		private var _enter:IEnter;
		private var _exit:IExit;
		
		private var _parentName:String;
		//private var _parent:IState;
		//private var _children:Array;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		// Todo(Hays) This logic should really be replaced by a builder
		public function State(stateName:String, stateData:Object = null) {
			_name = stateName;
			if (stateData == null) {
				stateData = {};
			}
			
			_from = stateData.from;
			if (!_from) {
				_from = WILDCARD;
			}
			
			_enter = (stateData.enter) ? stateData.enter : NO_ENTER;
			_exit = (stateData.exit) ? stateData.exit : NO_EXIT;
			
			_parentName = stateData.parent;
			//children = [];
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		//----------------------------------
		//  IState
		//----------------------------------
		//Todo(Hays) seems like getting the parent can only be handled by the StateMachine itself.
		
		/**
		public function init(stateMachineInstance:StateMachine):void {
			var nameOfParent:String = parentName;
			if (nameOfParent && stateMachineInstance.hasStateByName(nameOfParent)) {
				//Todo(Hays) This seems like it should be update with-in the machine?
				parent = stateMachineInstance.getStateByName(nameOfParent);
			}
		}
		**/
		
		public function allowTransitionFrom(stateName:String):Boolean {
			return (_from == WILDCARD
				|| _from.indexOf(stateName) != -1
			);
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get from():Object {
			return _from;
		}
			
		public function get enter():IEnter {
			return _enter;
		}
		
		public function get exit():IExit {
			return _exit;
		}
		
		public function toString():String {
			return this.name;
		}
		
		public function get parentName():String {
			return _parentName;
		}
		
		/**
		public function get parent():IState {
			return _parent;
		}
		
		//move
		public function set parent(parent:IState):void {
			_parent = parent;
			_parent.children.push(this);
		}
		
		//move 
		public function get parents():Array {
			var parentList:Array = [];
			var parentState:IState = _parent;
			if (parentState) {
				parentList.push(parentState);
				while (parentState.parent) {
					parentState = parentState.parent;
					parentList.push(parentState);
				}
			}
			return parentList;
		}
		
		public function get children():Array {
			return _children;
		}
		
		public function set children(children:Array):void {
			_children = children;
		}
		
		public function get root():IState {
			if(!_parent || _parent == NO_PARENT) {
				return this;
			}
			var parentState:IState = _parent;
			if (parentState) {
				while (parentState.parent) {
					parentState = parentState.parent;
				}
			}
			return parentState;
		}
		 **/
	}
}