// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IERC20Permit is IERC20 {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


contract ERC20PermitContract {
    using ECDSA for bytes32;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function permitTransfer(
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        bytes32 blindedMessage,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Déblinder le message pour obtenir l'adresse du signataire
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                blindedMessage
            )
        );
        address signatory = digest.recover(v, r, s);
        require(signatory == from, "Error: Invalid signature ");

        // Vérifier que la demande n'a pas expiré
        require(block.timestamp <= deadline, "Signature expired");

        // Utiliser la fonction permit pour approuver le transfert
        IERC20Permit(token).permit(from, address(this), amount, deadline, v, r, s);

        // Effectuer le transfert de tokens
        IERC20(token).transferFrom(from, to, amount);
    }

    receive() external payable {}

    function withdrawETH() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}
