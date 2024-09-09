// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {OrderNft, Project6551} from "./Project6551.sol";

contract Project is Ownable {
    uint256 public counter = 0;

    address registry;
    address payable implementation;

    event AddProject(uint256 projectId, string name, address token, uint256 TGETime, uint256 deliveryEndTime);
    event SetTGEInfo(uint256 projectId, address token, uint256 TGETime, uint256 deliveryEndTime);

    constructor(address _registry, address payable _implementation) Ownable(msg.sender) {
        registry = _registry;
        implementation = _implementation;
    }

    mapping(uint256 => PreProject) public preProjects; //项目id=>项目,如：1=>EIGEN，2=>SWELL

    function getProject(uint256 id) public view returns (PreProject memory) {
        return preProjects[id];
    }

    function addPreProject(
        string memory name,
        address token,
        uint256 TGETime,
        uint256 deliveryEndTime,
        uint256 pointRate
    ) public onlyOwner {
        Project6551 project6551 = new Project6551(registry, implementation, name);
        PreProject memory project = PreProject({
            id: counter++,
            name: name,
            token: token, //创建时不一定有，后续可以修改
            TGETime: TGETime, //创建时不一定有，后续可以修改
            deliveryEndTime: deliveryEndTime, //创建时不一定有，后续可以修改
            pointRate: pointRate, //创建时不一定有，后续可以修改
            project6551: project6551
        });
        preProjects[project.id] = project;
        emit AddProject(project.id, name, token, TGETime, deliveryEndTime);
    }

    /**
     * TGE之前，admin需要设置的三个参数
     */
    function setTGEInfo(address token, uint256 projectId, uint256 TGETime, uint256 deliveryEndTime) public onlyOwner {
        PreProject storage project = preProjects[projectId];
        project.token = token;
        project.TGETime = TGETime;
        project.deliveryEndTime = deliveryEndTime;
        emit SetTGEInfo(projectId, token, TGETime, deliveryEndTime);
    }

    /**
     * pre-market project
     */
    struct PreProject {
        uint256 id;
        string name; //项目名称
        address token; //代币erc20合约
        uint256 TGETime; //TGE时间
        uint256 deliveryEndTime; //交割时间
        uint256 pointRate; //一个积分换得多少token。point-Market使用
        Project6551 project6551;
    }
}
