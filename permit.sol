pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ERC20Permit {
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
        require(signatory == from, "Invalid signature");

        // Vérifier que la demande n'a pas expiré
        require(block.timestamp <= deadline, "Signature expired");

        // Autoriser le contrat à dépenser les tokens au nom de `from`
        IERC20(token).permit(from, address(this), amount, deadline, v, r, s);

        // Effectuer le transfert de tokens
        IERC20(token).transferFrom(from, to, amount);
    }

    receive() external payable {}

    function withdrawETH() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}
