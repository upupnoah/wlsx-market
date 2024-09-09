// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Project6551.sol";
import "../src/PreMarket.sol";
import "../src/Project.sol";
import "../test/BaseERC20.sol";
import "lib/erc6551/src/examples/simple/ERC6551Account.sol";
import "lib/erc6551/src/ERC6551Registry.sol";

contract PreMarketScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address registry6551 = vm.envUint("6551_REGISTRY");
        address payable account6551 = vm.envUint("6551_ACCOUNT");
        vm.startBroadcast(deployerPrivateKey);

        Project project = new Project(registry6551, account6551);
        PreMarket preMarket = new PreMarket(address(project));
        BaseERC20 token = new BaseERC20("EIGEN", "EIGEN");
        project.addPreProject("EIGEN", address(token), block.timestamp + 10 hours, block.timestamp + 20 hours, 0);

        vm.stopBroadcast();
    }
}
