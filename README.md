## solidity-exercises

## Important Links

## Setting Up Windows workstation


1. Install HomeBrew from website

``` 
https://brew.sh
```

2. Install iterm, zsh
```
brew install --cask iterm2
brew install zsh
```

3. Install oh-my-zshell

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

4. Install Git, Nodejs, npm
```
brew install git
brew install node
```

5. Install Truffle and Ganache
```
npm install -g truffle
npm install -g ganache-cli 
```
6. Initialize project
```
truffle init
```
7. Create a Solidity Contract
```
truffle create contract <ContractName>
```
8. Install Truffle for VS Code extension. This provides the following actions
```
Build Contracts
Deploy Contracts
```
9. Connect to truffle console
```
truffle console --network development
let contract = await Arrays.deployed()
contract.pushElement(10)
contract.pushElement(20)
contract.pushElement(30)
contract.printArray()
```
10. Redeploy the contracts
```
truffle migrate --reset
```

##  Deploying contract and calling contract functions to prod/test networks through remix

1. Go to DEPLOY & RUN TRANSACTIONS Tab in remix

2. From ENVIRONMENT dropdown choose
```
 Injected Provider - Metamask
```
This will connect to Network we selected in Metamask Wallet and also loads Account information from metamask

3. We can deploy the contract to test network or pull the existing contract from the test network

4. Call functions on the contract

##  Git Steps for Feature Branches

Create a new branch

```
    git checkout -b f-[featurename]
```

Get latest changes

```
    git pull
```

**Commiting changes to branch:**

1) Add all changes to git

```
    git add .
```

2) Commit changes

```
    git commit -m "message"
```

3) Push feature to remote feature branch

```
    git push origin <branch name>
```