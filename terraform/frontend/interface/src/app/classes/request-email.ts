const request_email_template = (message: any, user: any) => {
    const email_template = `<div> Hello,<br><br>Please approve the request for publishing the datasets.<br>
    <ul>
        <li>Dataset / Algorithm Name = ${message.dataset}</li>
        <li>Type = ${message.type}</li>
        <li>Category = ${message.category}</li>
        <li>File Name = ${message.name}</li>
        <li>Description = ${message.description}</li>
        <li>Readme / Data dictionary file name = ${message.readmeFileName}</li>
        <li>Geographic Scope = ${message.geographicScope}</li>
        <li>Start/End Date for Data Availability = ${message.dataAvailability}<br></li>
        <li>Sender Name = ${user.user_name}</li>
        <li>Sender E-mail id = ${user.email_address}</li>
    </ul>
    Thanks, ${user.user_name}<br>
</div>`;
}

export class RequestEmail {

    constructor() { }
}
