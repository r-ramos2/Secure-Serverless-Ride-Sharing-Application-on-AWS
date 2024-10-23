# **Secure Serverless Ride Sharing Application on AWS**

## **Introduction**

Welcome to the **Secure Serverless Ride Sharing Application** project! This project outlines the process of building a secure, scalable, and serverless ride-sharing application using various AWS services, including AWS Amplify, Lambda, DynamoDB, API Gateway, and Cognito. It emphasizes **cloud security best practices**, ensuring the application is resilient against common vulnerabilities while maintaining functionality and performance. This guide provides a detailed walkthrough to help you understand modern cloud architecture and implement security-first approaches.

## **Table of Contents**

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Setting Up Your Environment](#setting-up-your-environment)
4. [Creating the Frontend with AWS Amplify](#creating-the-frontend-with-aws-amplify)
5. [Configuring User Authentication with Cognito](#configuring-user-authentication-with-cognito)
6. [Implementing Ride Request Functionality with Lambda and DynamoDB](#implementing-ride-request-functionality-with-lambda-and-dynamodb)
7. [Creating the API with API Gateway](#creating-the-api-with-api-gateway)
8. [Security Best Practices](#security-best-practices)
9. [Testing the Application](#testing-the-application)
10. [Infrastructure as Code with Terraform](#infrastructure-as-code-with-terraform)
11. [Monitoring and Logging](#monitoring-and-logging)
12. [Cleaning Up Resources](#cleaning-up-resources)
13. [Conclusion](#conclusion)
14. [Resources](#resources)

---

## **1. Prerequisites**

Before starting this project, ensure you have:

- An active **AWS account** (sign up [here](https://aws.amazon.com/)).
- Familiarity with AWS services, particularly **IAM**, **Lambda**, **API Gateway**, **DynamoDB**, and **Cognito**.
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured.
- Working knowledge of **JavaScript**, HTML, and CSS.
- **Terraform** installed for infrastructure automation.

---

## **2. Architecture Overview**

This application implements a secure, serverless architecture using the following AWS services:

- **AWS Amplify**: Hosts the frontend application, providing continuous deployment capabilities.
- **Amazon Cognito**: Manages user authentication and authorization.
- **AWS Lambda**: Runs backend logic, including ride request processing.
- **Amazon DynamoDB**: NoSQL database for storing user and ride request data.
- **Amazon API Gateway**: Exposes secure REST APIs for communication between frontend and backend.
- **Amazon S3**: Stores static website assets.
- **Amazon CloudWatch**: Collects logs, monitors performance, and provides insights into application health.

<img width="858" alt="serverless-app-diagramp" src="https://github.com/user-attachments/assets/07512f36-9c20-4dd6-b948-942b66ab721d">

*Architecture Diagram*

### **Security Considerations**

- **IAM Role Separation**: Implementing **least privilege access** by using different IAM roles for each service, ensuring fine-grained permission control.
- **Data Encryption**: Encrypted data at rest in DynamoDB using AWS KMS. Enforcing HTTPS for secure transmission of data between client and server.
- **Multi-Factor Authentication (MFA)**: Enforcing MFA for sensitive operations through Cognito.
- **CORS Configuration**: Secure CORS settings on API Gateway to control cross-origin requests.
- **Environment Isolation**: Use of separate AWS accounts or environments (development, staging, production) to prevent unintended cross-environment impacts.

---

## **3. Setting Up Your Environment**

1. **Log in to the AWS Management Console**.
2. **Select AWS Region**: Ensure you are working in **US East (N. Virginia)** (`us-east-1`) or your preferred region.
3. **Install and configure AWS CLI**: Follow the AWS CLI [installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) to configure your access.
4. **Ensure Node.js is installed**: Install Node.js to manage your Lambda functions if not installed already.

---

## **4. Creating the Frontend with AWS Amplify**

1. **Open AWS Amplify Console**:
   - Navigate to the AWS Amplify section in the AWS Management Console.

2. **Create a New App**:
   - Under "Deploy," click "Host web app."
   - Connect your repository (e.g., GitHub) with the frontend code.

3. **Build Configuration**:
   - Customize build settings as needed, ensuring environment variables for API Gateway and Cognito Pool IDs are securely stored.
   - Use Amplify’s built-in environment variables feature to store API endpoints and sensitive credentials securely.

4. **Deploy the Application**:
   - Save and deploy your application. Amplify provides a domain URL for access, which you will use to test the app later.

---

## **5. Configuring User Authentication with Cognito**

### **Creating a Cognito User Pool**

1. **Navigate to Cognito**:
   - Open the Amazon Cognito console in the AWS Management Console.

2. **Create a User Pool**:
   - Name your pool (e.g., `RideShareUserPool`).
   - Set up strong password policies to enforce security (e.g., require uppercase, lowercase, numbers, and special characters).

3. **Create App Client**:
   - Add an app client (disable the generation of client secrets to enhance security).
   - Choose security configurations such as **OAuth Scopes** and **User Attribute validation** (use email as the primary login attribute).

4. **Domain Name Configuration**:
   - Set up a Cognito-hosted domain for user sign-in or integrate a custom domain for improved UX.

5. **Update Frontend Configuration**:
   - Modify your frontend to securely store Cognito’s User Pool ID and App Client ID using environment variables.

---

## **6. Implementing Ride Request Functionality with Lambda and DynamoDB**

### **Creating the DynamoDB Table**

1. **Open DynamoDB Console**:
   - Create a new table named `RideRequests`.
   - Set `rideID` as the partition key (String).
   - Enable **encryption at rest** using AWS-managed KMS keys.

### **Creating the Lambda Function**

1. **Open Lambda Console**:
   - Create a function named `RequestRideLambda` using Node.js 20.

2. **Define IAM Permissions**:
   - Attach policies for DynamoDB access to the Lambda execution role. Follow **least privilege** principles by limiting access to specific DynamoDB tables and operations.

3. **Code Implementation**:
   - Write the Lambda function code to handle ride requests. Ensure input validation and proper error handling to prevent injection attacks.
   - Deploy and test the Lambda function.

---

## **7. Creating the API with API Gateway**

1. **Open API Gateway Console**:
   - Create a new REST API (`RideShareAPI`).

2. **Create Resources and Methods**:
   - Define the `/rides` resource.
   - Create a `POST` method integrated with the `RequestRideLambda` function.
   - Enable **Lambda Proxy Integration** to pass requests directly to the Lambda function.

3. **Implement Security**:
   - Use **Amazon Cognito** as the authorizer for your API Gateway methods.
   - Restrict access to authorized users only by requiring authentication via Cognito.

4. **Deploy the API**:
   - Create a deployment stage (e.g., `dev`) and note the API invoke URL for testing.

---

## **8. Security Best Practices**

- **Secure API Gateway**: Implement rate limiting to prevent abuse, enforce strict CORS policies, and enable request validation to safeguard API endpoints.
- **IAM Role Best Practices**: Regularly rotate IAM credentials, minimize hardcoded credentials, and ensure logging of all IAM activities with CloudTrail.
- **Logging and Monitoring**: Enable CloudWatch to monitor Lambda invocations, API requests, and potential failures.
- **Use of KMS**: Leverage AWS Key Management Service (KMS) to handle all data encryption and decryption operations in DynamoDB.

---

## **9. Testing the Application**

1. **Access the Frontend**:
   - Use the Amplify-provided URL to access the web app.

2. **Register and Sign In**:
   - Register a new user via Cognito and confirm the email to complete registration.
   
3. **Submit a Ride Request**:
   - Use the interface to submit a ride request and validate that the data is securely stored in DynamoDB.
   
4. **Monitor Logs**:
   - Check CloudWatch logs to verify Lambda execution and identify any errors.

---

## **10. Infrastructure as Code with Terraform**

### **Setup Terraform**

1. **Create Directory & Initialize Terraform**:
   ```bash
   mkdir secure-serverless-ride-sharing
   cd secure-serverless-ride-sharing
   terraform init
   ```

### **Terraform Configuration**

Your Terraform configuration files (`main.tf`, `variables.tf`, `outputs.tf`) should include definitions for all AWS resources. Make sure to:

- Use variables for flexibility in configurations.
- Ensure **state locking** to prevent race conditions during deployment.
- Encrypt sensitive outputs and configurations.

### **Deploy with Terraform**

Run the following command to provision the infrastructure:
```bash
terraform apply
```
Carefully review changes and confirm to proceed.

---

## **11. Monitoring and Logging**

- **CloudWatch Logs**: Ensure CloudWatch is integrated with Lambda for real-time monitoring of request processing and error tracking.
- **AWS X-Ray**: Integrate AWS X-Ray to trace and analyze request flows, helping

 identify performance bottlenecks and potential vulnerabilities.
- **Cost Management**: Enable AWS Cost Explorer to monitor and optimize your application's cost and resource usage.

---

## **12. Cleaning Up Resources**

To avoid incurring unexpected charges, remove all resources when finished:

1. **Delete Amplify App**.
2. **Remove API Gateway APIs**.
3. **Delete Lambda functions**.
4. **Drop DynamoDB tables**.
5. **Run `terraform destroy`** to remove all provisioned infrastructure.

---

## **13. Conclusion**

By following this guide, you've built a fully functional, secure, and scalable ride-sharing application using serverless AWS technologies. You've applied cloud security best practices, ensuring that the application remains resilient and scalable. Continue exploring advanced topics like **CI/CD pipelines**, **auto-scaling**, and **disaster recovery** to enhance your application further.

---

## **14. Resources**

- [AWS Security Best Practices](https://aws.amazon.com/architecture/security/)
- [Amazon Cognito Developer Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [AWS API Gateway Security](https://docs.aws.amazon.com/apigateway/latest/developerguide/security.html)
- [Wild Rydes Serverless Workshop on GitHub](https://github.com/tinytechnicaltutorials/wildrydes-site?tab=readme-ov-file)
- [AWS Serverless Workshops](https://aws.amazon.com/serverless-workshops/)
