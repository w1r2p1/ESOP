pragma solidity ^0.4.0;

import "./ESOP.sol";
import "./RoT.sol";
import "./ERC20OptionsConverter.sol";
import "./ProceedsOptionsConverter.sol";

contract EmpTester {
  address _t;
  function _target( address target ) {
    _t = target;
  }
  function() payable {
    if (msg.data.length > 0) // do not call default function on target
      if(!_t.call(msg.data)) throw;
  }

  function forward(bytes4 signature, address a, uint256 v) returns (bool) {
    return _t.call(signature, a, v);
  }

  function employeeExerciseOptions() returns (uint8){
      return uint8(ESOP(_t).employeeExerciseOptions());
  }

  function employeeSignsToESOP() returns (uint8){
      return uint8(ESOP(_t).employeeSignsToESOP());
  }

  function calcEffectiveOptionsForEmployee(address e, uint32 calcAtTime) returns (uint) {
    return ESOP(_t).calcEffectiveOptionsForEmployee(e, calcAtTime);
  }

  function withdraw() returns (uint) {
    return ProceedsOptionsConverter(_t).withdraw();
  }

  function openESOP(uint32 pcliffPeriod, uint32 pvestingPeriod, uint32 pMaxFadeoutPromille, uint32 pbonusOptionsPromille,
    uint32 pNewEmployeePoolPromille, uint32 ptotalPoolOptions, bytes pESOPLegalWrapperIPFSHash) returns (uint8) {
      return uint8(ESOP(_t).openESOP(pcliffPeriod, pvestingPeriod, pMaxFadeoutPromille, pbonusOptionsPromille, pNewEmployeePoolPromille,
        ptotalPoolOptions, pESOPLegalWrapperIPFSHash));
    }
}

contract ESOPMaker {
  RoT public root;

  function makeNFESOP() public returns (ESOP) {
    root = new RoT();
    ESOP e = new ESOP(address(this), address(root));
    root.setESOP(e, address(this));
    //bytes32 ESOPLegalWrapperIPFSHash = sha256("hereby pool #1 is established");
    bytes memory ESOPLegalWrapperIPFSHash = "qmv8ndh7ageh9b24zngaextmuhj7aiuw3scc8hkczvjkww";
    // a few interesting parameter combinations
    // e.openESOP(1 years, 4 years, 8000, 2000, 1000, 1000000, ESOPLegalWrapperIPFSHash) - neufund
    // e.openESOP(0 years, 4 years, 8000, 2000, 1000, 1000000, ESOPLegalWrapperIPFSHash) - no cliff
    // e.openESOP(0 years, 0 years, 8000, 2000, 1000, 1000000, ESOPLegalWrapperIPFSHash) - no vesting
    // e.openESOP(1 years, 4 years, 10000, 2000, 1000, 1000000, ESOPLegalWrapperIPFSHash) - full fadeout
    // e.openESOP(1 years, 4 years, 0, 2000, 1000, 1000000, ESOPLegalWrapperIPFSHash) - no fadeout
    // e.openESOP(1 years, 4 years, 8000, 0, 1000, 1000000, ESOPLegalWrapperIPFSHash) - no bonus
    // e.openESOP(1 years, 4 years, 8000, 0, 0, 0, ESOPLegalWrapperIPFSHash) - no pool, just extra
    // make company sign this
    uint rc = uint(e.openESOP(1 years, 4 years, 8000, 2000, 1000, 997302, ESOPLegalWrapperIPFSHash));
    if (rc != 0)
      throw;
    return e;
  }
}

//contract ESOPTest is ESOP
