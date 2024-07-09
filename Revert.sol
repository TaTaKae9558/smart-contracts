// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Require {

    uint nombre;

    // old version
    function setNombreWihtRevert(uint _nombre) public {
        if (_nombre == 10) {
            revert('Error cannot be equal 10');
        }
        nombre = _nombre;
    }

    function setNombreWithRequire(uint _nombre) public {
        require(_nombre != 10, 'Error cannot be equal 10');
        nombre = _nombre;
    }

    function getNombre() public view returns(uint) {
        return nombre;
    }
}
