// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

contract NFTMarketplace {
    struct NFT {
        address owner;
        uint256 price;
        bool forSale;
        uint256 projectId;
    }
    
    struct Offer {
        address offerer;
        uint256 amount;
        bool active;
    }
    
    struct Project {
        uint256 totalPrimarySales;
        uint256 totalSecondarySales;
        uint256 floor;
        uint256 medianPrice;
        uint256 dailyPrimarySales;
        uint256 dailySecondarySales;
        address creator;
    }
    
    struct ProjectOffer {
        address offerer;
        uint256 amount;
        bool active;
    }
    
    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => ProjectOffer) public projectOffers; // Added mapping for project offers
    mapping(address => uint256[]) public userNFTs;
    mapping(uint256 => Project) public projects;
    
    uint256 public dailyPrimarySales;
    uint256 public dailySecondarySales;
    uint256 public dailyUsers;

    function putNFTForSale(uint256 tokenId, uint256 price, uint256 projectId) external {
        require(nfts[tokenId].owner == msg.sender, "Only NFT owner can put it for sale");
        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;
        nfts[tokenId].projectId = projectId;
        projects[projectId].floor = price; 
    }

    function acceptSale(uint256 tokenId) external payable {
        require(msg.value >= nfts[tokenId].price, "Not enough funds to accept");
        
        address previousOwner = nfts[tokenId].owner;
        
        nfts[tokenId].owner = msg.sender;
        nfts[tokenId].forSale = false;
        nfts[tokenId].price = 0;
        
        payable(previousOwner).transfer(msg.value);
        
        userNFTs[msg.sender].push(tokenId);
        
        uint256 projectId = nfts[tokenId].projectId;
        projects[projectId].totalPrimarySales++;
        projects[projectId].dailyPrimarySales++;
        dailyPrimarySales++;
        dailyUsers++;
    }

    function makeOffer(uint256 tokenId, uint256 amount) external {
        require(nfts[tokenId].owner != msg.sender, "Cannot make an offer on your own NFT");
        
        offers[tokenId].offerer = msg.sender;
        offers[tokenId].amount = amount;
        offers[tokenId].active = true;
    }

    function acceptOffer(uint256 tokenId) external payable {
        require(nfts[tokenId].owner == msg.sender, "Only NFT owner can accept an offer");
        require(offers[tokenId].active, "No active offer for this NFT");
        require(msg.value >= offers[tokenId].amount, "Insufficient funds to accept the offer");
        
        address previousOwner = nfts[tokenId].owner;
        
        nfts[tokenId].owner = msg.sender;
        nfts[tokenId].forSale = false;
        nfts[tokenId].price = 0;
        
        payable(previousOwner).transfer(msg.value);
        
        userNFTs[msg.sender].push(tokenId);
        
        uint256 projectId = nfts[tokenId].projectId;
        projects[projectId].totalSecondarySales++;
        projects[projectId].dailySecondarySales++;
        dailySecondarySales++;
        dailyUsers++;
        
        offers[tokenId].active = false;
    }

    function makeProjectOffer(uint256 projectId, uint256 amount) external {        
        projectOffers[projectId].offerer = msg.sender;
        projectOffers[projectId].amount = amount;
        projectOffers[projectId].active = true;
    }
    
    function acceptProjectOffer(uint256 projectId) external payable {
        require(projects[projectId].creator != address(0), "Project does not exist");
        require(msg.sender == projects[projectId].creator, "Only the project creator can accept an offer");
        require(projectOffers[projectId].active, "No active offer for this project");

        address previousOwner = projects[projectId].creator;
        address newOwner = projectOffers[projectId].offerer;
        uint256 offerAmount = projectOffers[projectId].amount;

        projects[projectId].creator = newOwner;
        projectOffers[projectId].active = false;

        payable(previousOwner).transfer(offerAmount);
    }
    
    function getOverallStatistics() external view returns (uint256, uint256, uint256) {
        return (dailyPrimarySales, dailySecondarySales, dailyUsers);
    }
    
    function getProjectOverallStatistics(uint256 projectId) external view returns (uint256, uint256, uint256, uint256, uint256) {
        return (
            projects[projectId].totalPrimarySales,
            projects[projectId].totalSecondarySales,
            projects[projectId].floor,
            projects[projectId].medianPrice,
            projects[projectId].dailyPrimarySales
        );
    }
}
