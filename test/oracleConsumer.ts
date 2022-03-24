import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { Stack, deployStack } from "../scripts/helpers";

describe("OracleConsumer.sol", function () {
  let stack: Stack;
  let contract: Contract;
  before(async function () {
    const [owner] = await ethers.getSigners();

    stack = await deployStack({ SOSMinter: owner.address });

    contract = stack.OracleConsumer;
  });
});
