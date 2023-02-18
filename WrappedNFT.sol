pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract WrappedNFTFactory {
    event NewContract(address indexed newContractAddress);

    function createContract(
        address _erc721Address,
        uint256 _amount,
        string memory _name,
        string memory _symbol
    ) public {
        string memory erc721TokenName = getTokenName(_erc721Address);
        string memory wrappedTokenName = string(
            abi.encodePacked("Wrapped ", erc721TokenName)
        );
        WrappedNFT newContract = new WrappedNFT(
            _erc721Address,
            _amount,
            wrappedTokenName,
            _symbol
        );
        emit NewContract(address(newContract));
    }

    function getTokenName(address _erc721Address)
        public
        view
        returns (string memory)
    {
        IERC721 erc721Token = IERC721(_erc721Address);
        return erc721Token.name();
    }
}

contract WrappedNFT is ERC20, Ownable {
    IERC721 public erc721Contract;
    uint256 public amount;

    constructor(
        address _erc721Address,
        uint256 _amount,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        erc721Contract = IERC721(_erc721Address);
        amount = _amount;
    }

    function wrap(uint256 tokenId) public {
        require(
            erc721Contract.ownerOf(tokenId) == msg.sender,
            "Only the owner of the NFT can wrap it"
        );
        erc721Contract.safeTransferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, amount);
    }

    function unwrap(uint256 tokenId) public {
        require(
            balanceOf(msg.sender) >= amount,
            "Insufficient balance to unwrap NFT"
        );
        _burn(msg.sender, amount);
        erc721Contract.safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
