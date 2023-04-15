/**
 * Before running the deployment script, make sure to copy `.env.example` in a `.env` file and set the environment variables. (Mainly the MAINNET_RPC_URL, DEPLOYER_PK and ETHERSCAN_API_KEY vars)
 * This script can be executed using the below command:
 * - source .env
 * - forge script script/SqueethOldDeploymentsScript.s.sol:SqueethOldDeploymentsScript --rpc-url $MAINNET_RPC_URL -vv
 */
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

// data structures
struct Vault {
    // the address that can update the vault
    address operator;
    // uniswap position token id deposited into the vault as collateral
    // 2^32 is 4,294,967,296, which means the vault structure will work with up to 4 billion positions
    uint32 NftCollateralId;
    // amount of eth (wei) used in the vault as collateral
    // 2^96 / 1e18 = 79,228,162,514, which means a vault can store up to 79 billion eth
    // when we need to do calculations, we always cast this number to uint256 to avoid overflow
    uint96 collateralAmount;
    // amount of wPowerPerp minted from the vault
    uint128 shortAmount;
}

// interfaces
interface IController {
    function weth() external view returns (address);
    function quoteCurrency() external view returns (address);
    function ethQuoteCurrencyPool() external view returns (address);
    function wPowerPerp() external view returns (address);
    function wPowerPerpPool() external view returns (address);
    function oracle() external view returns (address);
    function vaults(uint256 vaultId) external view returns (Vault memory);
}

interface IShortPowerPerp {
    function nextId() external view returns (uint256);
}

contract SqueethOldDeploymentsScript is Script {
    // old dep1
    address controllerDep1 = 0x4c1fd946A082d26b40154EabD12F7A15a0cB3020;
    address shortPowerPerpDep1 = 0x4ff8329eea2537956bdd227397B14D85A801eC89;
    
    // old dep2
    // address controllerDep1 = 0x0344f8706947321FA87881D3DaD0EB1b8C65E732;
    // address shortPowerPerpDep1 = 0x4757F744ec0CF2e3500Dc655F55100C943a59cbb;

    // mainnet
    // address controllerDep1 = 0x64187ae08781B09368e6253F9E94951243A493D5;
    // address shortPowerPerpDep1 = 0xa653e22A963ff0026292Cc8B67941c0ba7863a38;

    IController internal controller;
    IShortPowerPerp internal shortPowerPerp;

    function setUp() public {
        controller = IController(controllerDep1);
        shortPowerPerp = IShortPowerPerp(shortPowerPerpDep1);
    }

    function run() public view {
        uint256 vaultsNumber = shortPowerPerp.nextId();

        console.log("Controller balance in ETH", address(controller).balance);

        for(uint256 i=1; i < vaultsNumber; ++i) {
            (address op, uint32 nftId, uint96 collateralAmt, uint128 shortAmt) = getVaultDetails(i);

            if(collateralAmt > 0 || nftId > 0) {
                console.log("Vault ID", i, ":");
                console.log("op", op);
                console.log("nftId", nftId);
                console.log("collateralAmt", collateralAmt);
                console.log("shortAmt", shortAmt);
            }
        }
    }

    function getVaultDetails(uint256 _vaultId) internal view returns (address, uint32, uint96, uint128) {
        Vault memory vault = controller.vaults(_vaultId);

        return (vault.operator, vault.NftCollateralId, vault.collateralAmount, vault.shortAmount);
    }
}
