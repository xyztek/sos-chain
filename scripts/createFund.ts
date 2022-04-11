import { Contract } from "ethers";
import hre, { ethers } from "hardhat";

import { asBytes32, deployERC20 } from "./helpers";

async function main() {
  try {
    const [_owner, _EOA1, _EOA2] = await ethers.getSigners();

    const { getNamedAccounts } = hre;
    const { safe } = await getNamedAccounts();

    const REGISTRY_ADDRESSES: Record<string, string> = {
      rinkeby: "0x9543127f4483364200aA99b6C10B8c8C9Ce364Cb",
      localhost: "0x3262A1f3948c171725B254e2ff69aE40904F5a37",
      fuji: "0x3262A1f3948c171725B254e2ff69aE40904F5a37",
    };

    const registry: Contract = (
      await ethers.getContractFactory("Registry")
    ).attach(REGISTRY_ADDRESSES[hre.network.name]);

    const fundManagerAddress = await registry.get(asBytes32("FUND_MANAGER"));

    const fundManager: Contract = (
      await ethers.getContractFactory("FundManager")
    ).attach(fundManagerAddress);

    const ERC20 = await deployERC20();

    const USDC: Record<string, string> = {
      rinkeby: "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b",
      fuji: "0x45ea5d57BA80B5e3b0Ed502e9a08d568c96278F9",
      localhost: ERC20.address,
    };

    const SAFE: Record<string, string[]> = {
      rinkeby: [
        "0xF35164F058F1b85E277C306dc743ab82b94212dC",
        "0x51A41061E6eC0f460cd537D6B46ef3CefaC78937",
      ],
      fuji: [
        "0x934bA6747D1551058b71f5F7051b0Ae24F32B71E",
        "0x51A41061E6eC0f460cd537D6B46ef3CefaC78937",
      ],
      localhost: [safe, safe],
    };

    const defaultChecks = [
      "VERIFY RECIPIENT",
      "VERIFY RECIPIENT ADDRESS",
      "VERIFY LOCATION",
    ].map((check) => [
      asBytes32(check),
      "0x3563623638623961653932303438623339616163626536333036623135363033",
    ]);

    const funds = [
      {
        name: "SOS Oracle",
        focus: "Natural Disaster",
        description: `
SOS Wildfires Fund is a contribution raised to reduce the causes of wildfires, compensate their effects and carry out relevant field missions to take precautions.
A wildfire, forest fire, bush fire, wild-land fire or rural fire is an unplanned, unwanted, uncontrolled fire in an area of combustible vegetation starting in rural areas and urban areas.
Depending on the type of vegetation present, a wildfire can also be classified more specifically as a forest fire, brush fire, desert fire, grass fire, hill fire, peat fire, prairie fire, vegetation fire, or veld fire. Wildfires are distinct from beneficial uses of fire, called controlled burns; though controlled burns can turn into wildfires.
`,
      },
    ];

    const whitelist = "0xeeAfBc6271834926F016c08318d28258Ca63b931";
    for (const [i, fund] of funds.entries()) {
      await fundManager.createFund(
        fund.name,
        fund.focus,
        fund.description,
        SAFE[hre.network.name][i],
        [USDC[hre.network.name]],
        true,
        defaultChecks,
        [whitelist]
      );

      const fundAddress = await fundManager.getFundAddress(i);

      const auditors = ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"];
      const approvers = [
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        "0x1E15c548161F8a1859a8892dd61d102aD33c4829",
        "0x12b6272E0EA025EEF30d1C8481C85C2c2Ad57421",
        "0xEB6BE041000438400816eF46224f4aa17Ca316D7",
      ];

      const FundV1: Contract = (
        await ethers.getContractFactory("FundV1")
      ).attach(fundAddress);

      for (const approver of approvers) {
        await (
          await FundV1.grantRole(
            ethers.utils.keccak256(ethers.utils.toUtf8Bytes("APPROVER_ROLE")),
            approver
          )
        ).wait();
      }

      for (const auditor of auditors) {
        await (
          await FundV1.grantRole(
            ethers.utils.keccak256(ethers.utils.toUtf8Bytes("AUDITOR_ROLE")),
            auditor
          )
        ).wait();
      }
    }
  } catch (error) {
    console.log(error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
