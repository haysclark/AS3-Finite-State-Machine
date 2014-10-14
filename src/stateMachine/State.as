package stateMachine
{
	public class State implements IState
	{
		//----------------------------------
		//  CONSTS
		//----------------------------------
		public static const NO_ENTER:IEnter = new NoopEnter();
		public static const NO_EXIT:IExit = new NoopExit();
		public static const NO_PARENT:IState = new NoParentState(null);
		
		public static const WILDCARD:String = "*";
		
		//----------------------------------
		//  vars
		//----------------------------------
		private var _name:String;
		private var _from:Object;
		private var _enter:IEnter;
		private var _exit:IExit;
		
		private var _parent:IState;
		private var _parentName:String;
		private var _children:Array;
		
		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		public function State(stateName:String, stateData:Object = null) {
			_name = stateName;
			if (stateData == null) {
				stateData = {};
			}
			
			_from = stateData.from;
			if (!_from) {
				_from = WILDCARD;
			}
			_enter = stateData.enter;
			_exit = stateData.exit;
			
			_parentName = stateData.parent;
			children = [];
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		//----------------------------------
		//  IState
		//----------------------------------
		public function allowTransitionFrom(stateName:String):Boolean {
			return (_from.indexOf(stateName) != -1 || from == WILDCARD);
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
		
		//Todo(Hays) seems like getting the parent can only be handled by the StateMachine itself.
		public function init(stateMachineInstance:StateMachine):void {
			if (parentName) {
				parent = stateMachineInstance.states[parentName] as IState;
			}
		}
		
		public function get parent():IState {
			return _parent;
		}
		
		public function set parent(parent:IState):void {
			_parent = parent;
			_parent.children.push(this);
		}
		
		public function get parentName():String {
			return _parentName;
		}
		
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
			var parentState:IState = _parent;
			if (parentState) {
				while (parentState.parent) {
					parentState = parentState.parent;
				}
			}
			return parentState;
		}
	}
}