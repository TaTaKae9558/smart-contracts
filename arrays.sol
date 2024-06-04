// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20; 

contract arrays {
    uint[] nombre;

    function addValue(uint _value) public {
        nombre.push(_value);
    }

    function updateValue(uint _value, uint _index) public {
        nombre[_index] = _value;
    }

    function deleteValue(uint _index) public {
        delete nombre[_index];
    }

    function getValueAtIndex(uint _index) public view returns(uint) {
        return nombre[_index];
    }

    function getNombreX2() public view returns(uint[] memory) {
        uint longueur = nombre.length;
        uint[] memory nombreX2 = new uint[](longueur);
        for(uint i = 0; i < longueur; i++) {
            nombreX2[i] = nombre[i] * 2;
        }
        return nombre;
    }

    function some(uint[] memory someTable) public pure returns(uint[] memory) {
        return someTable;
    }
}
