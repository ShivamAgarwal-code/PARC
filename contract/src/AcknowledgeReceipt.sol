// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {Gateway} from "./Gateway.sol";

contract AcknowledgeReceipt is ERC721URIStorage {
    
    // Secret Network Testnet
    string constant public task_destination_network = "pulsar-3";

    // FIXME :: Contract conde hash
    // string public routing_contract = "secret1eh49wvgz6jkum4gfz2kep8nk3lzh2qr79xyfhl";
    // string constant public routing_code_hash = "05ea2138f2d32726f4a6fa88ed7281e3d9c31fd2bf36e2a39c58f4ba2c210277";

    uint256 private _nextTokenId;

    // Original Sender & Recipient of the given NFT
    mapping(uint256 => address) sender;
    mapping(uint256 => address) recipient;

    // Indicate if the recipient has reveal the NFT content
    mapping(uint256 => address) public reveal;

    string secretSmartContractAddress;

    event RevealEvent(uint256 indexed tokenId, address indexed recipient);

    address owner;

    modifier onlyOwner{
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Gateway to send message to secret network
    // Contract deployed on SEI Devnet
    // https://docs.scrt.network/secret-network-documentation/confidential-computing-layer/ethereum-evm-developer-toolkit/supported-networks/evm/evm-testnet-gateway-contracts
    address immutable secretGatewayAddress = 0x8EaAB5e8551781F3E8eb745E7fcc7DAeEFd27b1f;

    constructor() ERC721("AcknowledgeReceipt", "ART") {
        owner = msg.sender;
    }

    // function setRoutingContractAddress(string memory secretContract) external onlyOwner {
    //     routing_contract = secretContract;
    // }

    function getSenderAndRecipient(uint256 tokenId) view public returns (address, address) {
        return (sender[tokenId], recipient[tokenId]);
    }

    function createReceipt(
        address _recipient, 
        string memory tokenURI, 
        // string calldata encryptedMessage,
        bytes32 _payloadHash,
        string calldata _routingInfo,
        Gateway.ExecutionInfo calldata _info
    )
        public
        payable
        returns (uint256)
    {
        // Mint a new NFT
        uint256 tokenId = _nextTokenId++;
        _mint(_recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        sender[tokenId] = msg.sender;
        recipient[tokenId] = _recipient;

        // FIXME :: The full payload should be created here
        //          We should not rely on client side
        Gateway gateway = Gateway(secretGatewayAddress);
        gateway.send{value: msg.value}(
            _payloadHash,
            msg.sender,
            _routingInfo,
            _info
        );

        return tokenId;
    }

    function revealData(
        uint256 tokenId,
        // string calldata encryptedMessage,
        bytes32 _payloadHash,
        string calldata _routingInfo,
        Gateway.ExecutionInfo calldata _info
    ) public payable {
        require(msg.sender == _ownerOf(tokenId), "NOT_OWNER");

        reveal[tokenId] = msg.sender;

        // Call secret smart contract
        // FIXME: Need to built the payload in the smart contract else sneaky person can
        // call send with the reveal inside...
        // FIXME: The full payload should be created here
        //          We should not rely on client side
        Gateway gateway = Gateway(secretGatewayAddress);
        gateway.send{value: msg.value}(
            _payloadHash,
            msg.sender,
            _routingInfo,
            _info
        );

        emit RevealEvent(tokenId, msg.sender);
    }

    function getLastTokenId() public view returns(uint256) {
        return _nextTokenId;
    }


    // function sendMessage(string memory action, bytes memory payload) public {
    //     // We expect only two type of message:
    //     // "store" 
    //     // "add_view"

    //     // FIXME add a check on action to match existing one

    //     bytes memory emptyBytes = hex"0000";

    //     Gateway.ExecutionInfo memory executionInfo = Gateway.ExecutionInfo({
    //         user_key: emptyBytes,
    //         user_pubkey: emptyBytes,
    //         routing_code_hash: routing_code_hash,
    //         task_destination_network: task_destination_network,
    //         handle: action,
    //         nonce: bytes12(0),
    //         callback_gas_limit: 300000,
    //         payload: payload,
    //         payload_signature: emptyBytes
    //     });

    //     Gateway gateway = Gateway(secretGatewayAddress);
    //     gateway.send(
    //         payloadHash,
    //         msg.sender,
    //         routing_contract,
    //         executionInfo
    //     );
    // }

}
