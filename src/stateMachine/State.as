package stateMachine
{
	public class State implements IState
	{
		//----------------------------------
		//  CONSTS
		//----------------------------------
		public static const NO_ENTER:IEnter = new NoopEnter();
		public static const NO_EXIT:IExit = new NoopExit();
		
		public static const WILDCARD:String = "*";
		public static const NO_PARENT:String = null;
		
		//----------------------------------
		//  vars
		//----------------------------------
		private var _name:String;
		private var _parentName:String;
		private var _from:Array;
		private var _onEnter:IEnter;
		private var _onExit:IExit;
		
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
			
			if(!stateData.from) {
				_from = [WILDCARD];
			} else if(stateData.from as Array) {
				_from = stateData.from;
			} else if (stateData.from as String ) {
				_from = String(stateData.from).split(",");
			}
			
			_onEnter = (stateData.enter) ? stateData.enter : NO_ENTER;
			_onExit = (stateData.exit) ? stateData.exit : NO_EXIT;
			
			_parentName = (stateData.parent) ? stateData.parent : NO_PARENT;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		//----------------------------------
		//  IState
		//----------------------------------		
		public function get name():String {
			return _name;
		}
		
		public function get from():Array {
			return _from;
		}
			
		public function get onEnter():IEnter {
			return _onEnter;
		}
		
		public function get onExit():IExit {
			return _onExit;
		}
		
		public function get parentName():String {
			return _parentName;
		}
	}
}