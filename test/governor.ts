import { expect } from "chai";
import { ethers } from "hardhat";

import { deployStack, Stack } from "../scripts/helpers";

describe("Governor.sol", function () {
  let stack: Stack;

  before(async () => {
    stack = await deployStack();
  });

  it("should create a request", async function () {
    await expect(
      stack.Governor.createRequest(
        ethers.utils.formatBytes32String("TEST"),
        10000,
        "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512",
        0,
        [0, 0]
      )
    ).to.emit(stack.Governor, "RequestCreated");
  });
});
