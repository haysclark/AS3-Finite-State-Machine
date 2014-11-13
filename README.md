AS3-Hierarchical-State-Machine [![Build Status](https://travis-ci.org/haysclark/as3-hierarchical-state-machine.svg?branch=master)](https://travis-ci.org/haysclark/as3-hierarchical-state-machine)
========================

About
-----
This package allows you to create simple and layered or hierarchical finite state machines.  State Machines are composed of states, and each state has (optional) callbacks for entering and exiting state. It's also possible to restrict the transition from states using the _from_ property.

  * [Finite State Machines (FSM) ](http://ai-depot.com/FiniteStateMachines/FSM.html)

Project forked from AS3-State-Machine, by Cássio S. Antonio.<br>
Refactoring and UnitTested by Hays Clark

Usage
-----
Available states can be set with addState and initial state can be set using initialState setter.

The following example creates a state machine for a player model with 3 states (Playing, paused and stopped)

		 playerSM = new StateMachine();
		 playerSM.addState("playing",{ enter: onPlayingEnter, exit: onPlayingExit, from:["paused","stopped"] });
		 playerSM.addState("paused",{ enter: onPausedEnter, from:"playing"});
		 playerSM.addState("stopped",{ enter: onStoppedEnter, from:"*"});
		 
		 playerSM.addEventListener(StateMachineEvent.TRANSITION_DENIED,transitionDeniedFunction);
		 playerSM.addEventListener(StateMachineEvent.TRANSITION_COMPLETE,transitionCompleteFunction);
		 
		 playerSM.initialState = "stopped";


It's also possible to create hierarchical state machines using the argument "parent" in the addState method. This example shows the creation of a hierarchical state machine for the monster of a game (Its a simplified version of the state machine used to control the AI in the original Quake game)

		 monsterSM = new StateMachine()
		 
		 monsterSM.addState("idle",{enter:onIdle, from:"attack"})
		 monsterSM.addState("attack",{enter:onAttack, from:"idle"})
		 monsterSM.addState("melee attack",{parent:"atack", enter:onMeleeAttack, from:"attack"})
		 monsterSM.addState("smash",{parent:"melee attack", enter:onSmash})
		 monsterSM.addState("punch",{parent:"melee attack", enter:onPunch})
		 monsterSM.addState("missle attack",{parent:"attack", enter:onMissle})
		 monsterSM.addState("die",{enter:onDead, from:"attack", enter:onDie})
		 
		 monsterSM.initialState = "idle"
		 
License
-------
Copyright (c) 2014 Hays Clark <br>
Copyright (c) 2009-10 Cássio S. Antonio

AS3-FSM is released under the Open Source MIT license, which gives you the possibility to use it and modify it in every circumstance.