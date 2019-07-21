# AWS Terraform Exercise
A Demo Exercise for rains.tung 

This is an excercise to test your AWS knowledge with Terraform, Git and some basic scripting.

If you've used Gitlab before feel free to make use of its "Issues Board" if you find it helpful, but it's really not necessary.  If you've any questions regarding these exercises please email [Airwalk DevOps](mailto:devops@airwalkconsulting.io) for help.  We appreciate your time investment completing these tests so we've aimed to keep them achievable within about 2 hours - if you find it takes significantly longer then please complete as much as you feel is reasonable, and let us know of any problems.

Each requested feature from the four exercises below should have its own branch named `exercise-1|2|3|4` and merged on completion into master, but not deleted. Please take care with meaningful commit messages.

Any notes or comments should go in `NOTES.md`.

This base Terraform builds a simple VPC with just one instance running an Nginx server, with the default configuration, serving a simple welcome page (source can be found in the `artifacts` folder).

It's recommended you start by applying this Terraform code to your own AWS account using the variables file: `oregon.tfvars` to ensure you have a working starting-point. **Avoid checking any of your personal credentials into this repository**, then follow the four exercises below to add the requested features.


Exercises:

1. The product owner has decided maintenance of the website artifacts should be delegated to another team; their preference is to upload a zipped-tarball of artifacts to S3.  Implement change(s) so that:
   * an S3 bucket contains a zipped-tarball of the baseline site artifacts
   * the current set of artifacts can be retrieved by the site's EC2 instance upon launch (to keep things simple they will recycle the instance to make changes visible)

2. The single EC2 instance running Nginx went down over the weekend resulting in an outage. Please implement a solution that demonstrates best practice resilience within a single region. Not being a mission critical service, an outage of up to 4 minutes is acceptable upon failure/recovery.

3. Somebody has defaced the site by modifying the artifacts in S3, damaging the company's reputation.  The product owner wants access to the bucket restricted to designated individuals (and if possible, accessible only via the VPC).  Implement changes that restrict access to the bucket and its contents as securely as possible, making use of all AWS methods you care to use.

4. The product owner has decided that changes to the artifacts in S3 should become visible on the site without the need to manually recycle EC2 instances, and identified Lambda as the solution.  Implement a Lambda Function which detects changes to the S3 bucket and causes the site's EC2 instances to retrieve the updated contents.
# tf
