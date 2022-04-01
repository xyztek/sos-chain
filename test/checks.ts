import { expect } from "chai";
import { Contract } from "ethers";

import { asBytes32, deployContract } from "../scripts/helpers";

describe("Checks.sol", function () {
  let library: Contract;

  before(async () => {
    library = await deployContract(
      "contracts/test/ChecksInternalFnTester.sol:ChecksInternalFnTester"
    );
  });

  it("should determine if a check is automated", async function () {
    const automated = [asBytes32("TEST_CHECK_001"), asBytes32("someJobId")];
    expect(await library.isAutomated(automated)).to.eq(true);
  });

  it("should determine if a check is not automated", async function () {
    const nonAutomated = [asBytes32("TEST_CHECK_001"), asBytes32("")];
    expect(await library.isAutomated(nonAutomated)).to.eq(false);
  });
});
