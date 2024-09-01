import React, { useState } from 'react';
import { ethers } from 'ethers';
import './App.css';

function App() {
    const [provider, setProvider] = useState(null);
    const [signer, setSigner] = useState(null);
    const [status, setStatus] = useState('Not connected');
    const [signature, setSignature] = useState('');
    const [blindedMessage, setBlindedMessage] = useState('');

    const ERC20_CONTRACT_ADDRESS = '0xYourERC20ContractAddress';
    const PERMIT_CONTRACT_ADDRESS = '0xYourPermitContractAddress';
    const RECIPIENT_ADDRESS = '0xRecipientAddress';
    const AMOUNT_TO_APPROVE = ethers.utils.parseUnits("10.0", 18);

    const ERC20_ABI = [
        "function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external",
        "function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)"
    ];

    const PERMIT_ABI = [
        "function permitTransfer(address token, address from, address to, uint256 amount, uint256 deadline, bytes32 blindedMessage, uint8 v, bytes32 r, bytes32 s) external"
    ];

    const connectMetaMask = async () => {
        if (typeof window.ethereum !== 'undefined') {
            try {
                await window.ethereum.request({ method: 'eth_requestAccounts' });
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                
                setProvider(provider);
                setSigner(signer);
                setStatus('MetaMask connected');
            } catch (error) {
                console.error("User denied account access", error);
                setStatus("Access denied");
            }
        } else {
            console.error("MetaMask is not installed");
            setStatus("MetaMask is not installed. Please install MetaMask and try again.");
        }
    };

    const blindSignature = async () => {
        const domain = {
            name: "YourToken",
            version: "1",
            chainId: 11155111, // Sepolia testnet chainId
            verifyingContract: ERC20_CONTRACT_ADDRESS
        };

        const types = {
            Permit: [
                { name: "owner", type: "address" },
                { name: "spender", type: "address" },
                { name: "value", type: "uint256" },
                { name: "deadline", type: "uint256" }
            ]
        };

        const nonce = await signer.getTransactionCount();
        const deadline = Math.floor(Date.now() / 1000) + 60 * 60;

        const permitData = {
            owner: await signer.getAddress(),
            spender: PERMIT_CONTRACT_ADDRESS,
            value: AMOUNT_TO_APPROVE.toString(),
            deadline: deadline
        };

        const message = ethers.utils.defaultAbiCoder.encode(
            ["address", "address", "uint256", "uint256"],
            [permitData.owner, permitData.spender, permitData.value, permitData.deadline]
        );

        const blindingKey = ethers.utils.randomBytes(32);
        const blindedMessage = ethers.utils.solidityKeccak256(
            ["bytes32", "bytes32"],
            [ethers.utils.keccak256(message), ethers.utils.keccak256(blindingKey)]
        );

        const signature = await signer.signMessage(blindedMessage);
        const { v, r, s } = ethers.utils.splitSignature(signature);

        setBlindedMessage(blindedMessage);
        setSignature({ v, r, s });
    };

    const submitBlindedData = async () => {
        const permitContract = new ethers.Contract(PERMIT_CONTRACT_ADDRESS, PERMIT_ABI, signer);
        try {
            const tx = await permitContract.permitTransfer(
                ERC20_CONTRACT_ADDRESS,
                await signer.getAddress(),
                RECIPIENT_ADDRESS,
                AMOUNT_TO_APPROVE,
                Math.floor(Date.now() / 1000) + 60 * 60,
                blindedMessage,
                signature.v,
                signature.r,
                signature.s
            );
            await tx.wait();
            setStatus("Transfer successful");
        } catch (error) {
            console.error("Failed to transfer token:", error);
            setStatus("Transfer failed");
        }
    };

    return (
        <div>
            <button onClick={connectMetaMask}>Connect with MetaMask</button>
            <button onClick={blindSignature} disabled={!signer}>Generate Blind Signature</button>
            <button onClick={submitBlindedData} disabled={!blindedMessage}>Submit Blind Data</button>
            <p>{status}</p>
        </div>
    );
}

export default App;
