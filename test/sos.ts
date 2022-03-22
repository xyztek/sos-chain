import { expect } from "chai";
import { Contract, EventFilter } from "ethers";
import { ethers } from "hardhat";

import {
  createFund,
  deployERC20,
  deployStack,
  Stack,
} from "../scripts/helpers";
import testSVG from "./testSVG";

describe("SOS.sol", function () {
  let stack: Stack;
  let ERC20: Contract;

  before(async function () {
    const [owner] = await ethers.getSigners();

    stack = await deployStack({ SOSMinter: owner.address });

    ERC20 = await deployERC20();
  });

  it("should mint an ERC721", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    await expect(() => stack.SOS.mint(EOA1.address, 0)).to.changeTokenBalance(
      stack.SOS,
      EOA1,
      1
    );
  });

  it("should return a token URI for an ERC721", async function () {
    const [owner, EOA1] = await ethers.getSigners();

    await createFund(stack.FundManager, [ERC20.address], owner.address);

    const donationAmount = ethers.utils.parseUnits(
      "120",
      await ERC20.decimals()
    );

    await ERC20.transfer(EOA1.address, donationAmount);
    await ERC20.connect(EOA1).approve(stack.Donation.address, donationAmount);
    await stack.Donation.connect(EOA1).donate(0, ERC20.address, donationAmount);

    const filter: EventFilter = stack.SOS.filters.Transfer(null, EOA1.address);
    await new Promise(async (resolve, reject) => {
      stack.SOS.once(filter, async (_from, _to, tokenId) => {
        try {
          const tokenURI = await stack.SOS.tokenURI(tokenId);
          const encodedSVG = Buffer.from(testSVG(EOA1.address)).toString(
            "base64"
          );
          const buffer = Buffer.from(
            `{"name":"SOS Chain", "description": "SOS Chain Donation NFT", "image": "data:image/svg+xml;base64,${encodedSVG}"}`
          );
          const [def, encoded] = tokenURI.split(",");
          const encodedBuffer = buffer.toString("base64");
          expect(def).to.equal("data:application/json;base64");
          expect(encoded).to.equal(encodedBuffer);
          resolve(true);
        } catch (e) {
          reject(e);
        }
      });
    });
  });
});
