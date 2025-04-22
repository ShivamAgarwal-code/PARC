use cosmwasm_std::StdError;
use thiserror::Error;
use hex::FromHexError;

#[derive(Error, Debug, PartialEq)]
pub enum ContractError {

    /// Import From<StdError>
    #[error("{0}")]
    Std(#[from] StdError),

    /// Import From<FromHexError>
    #[error("{0}")]
    FromHexError(#[from] FromHexError),

    #[error("Custom Error val: {val:?}")]
    CustomError { val: String },

    #[error("The provided public key is invalid: {val:?}")]
    InvalidPublicKey { val: String },

    #[error("The symmetric encryption has failed for some reason.")]
    EncryptionError,

    #[error("The provided execute message encrypted is unknown.")]
    UnknownExecutePermitMsg,

    #[error("Error when deserialize the Permit message encrypted. More detail: {val:?}")]
    ErrorDeserializeExectueMsg {val: String},

    #[error("Invalid file id. The file does not seems to exists.")]
    InvalidFileID,

    #[error("Unknown handle.")]
    UnknownContractHandle,

    
}
