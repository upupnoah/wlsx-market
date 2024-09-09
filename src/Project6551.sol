// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "lib/erc6551/src/examples/simple/ERC6551Account.sol";
import "lib/erc6551/src/ERC6551Registry.sol";

/**
 * 一个project是一个ERC721合约
 *  每个用户只铸造一个父NFT
 */
contract Project6551 is ERC721Enumerable {
    uint256 counter = 0;
    ERC6551Registry public registry;
    ERC6551Account public implementation;
    OrderNft public sellOrderNft;
    OrderNft public buyOrderNft;

    constructor(address _registry, address payable _implementation, string memory name) ERC721(name, name) {
        registry = ERC6551Registry(address(_registry));
        implementation = ERC6551Account(_implementation);
        sellOrderNft = new OrderNft();
        buyOrderNft = new OrderNft();
    }

    function mint(address to, uint256 orderId, bool sell) external returns (address) {
        uint256 balance = balanceOf(to);
        address addr;
        if (balance == 0) {
            //不存在父NFT，铸造一个，生成TBA
            _mint(to, counter);
            addr = registry.createAccount(address(implementation), 0, block.chainid, address(this), counter);
            counter++;
        } else {
            //存在父NFT，找到一个，获取TBA
            uint256 tokenId = tokenOfOwnerByIndex(to, 0);
            addr = registry.account(address(implementation), 0, block.chainid, address(this), tokenId);
        }
        //向TBA铸造一个子NFT
        sell ? sellOrderNft.mint(addr, orderId) : buyOrderNft.mint(addr, orderId);

        //Creates a token bound account for a non-fungible token.

        // IERC6551Account accountInstance = IERC6551Account(payable(account));
        // IERC6551Executable executableAccountInstance = IERC6551Executable(account);
    }

    //TODO 销毁子NFT
    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function ownerOfSeller(uint256 tokenId, uint256 orderId) external view returns (bool) {
        address addr = registry.account(address(implementation), 0, block.chainid, address(this), tokenId);
        return addr == sellOrderNft.ownerOf(orderId);
    }

    // function mintChild(address to, uint256 id, uint256 orderId) external {
    //     address account = registry.account(address(implementation), 0, block.chainid, address(this), id);
    //     orderNft.mint(account, orderId);
    // }
}

// contract MyERC6551Account is ERC6551Account, IERC721Receiver {
//     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
//         external
//         returns (bytes4)
//     {
//         return this.onERC721Received.selector;
//     }
//}

contract OrderNft is ERC721 {
    constructor() ERC721("ChildOrder", "ChildOrder") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}
