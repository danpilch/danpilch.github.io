---
layout: post
title: Kubernetes Health Checks and ALB - Lessons Learned the Hard Way 
last_updated: 2021-02-09
category: community
---

# Kubernetes Health Checks and ALB: Lessons Learned the Hard Way  

When setting up Kubernetes health checks with an AWS Application Load Balancer (ALB), we ran into a few challenges and had to refine our approach through trial and error. Here’s what we learned and the best practice we landed on.

## Understanding Kubernetes Health Checks  

Kubernetes provides **two (now three)** types of health checks:  

1. **Liveness Probe** – Should always return `200 OK` unless the container is in a fatal state and needs to be restarted.  
2. **Readiness Probe** – Should return `200 OK` only when the application is fully ready to serve traffic.  
3. **Startup Probe** – (A newer option) Can be used to delay liveness and readiness checks until the app has finished initializing.

How these interact with an **ALB** is critical to ensure smooth deployments and graceful shutdowns.

## Our Approach to Health Checks and ALB  

We configure the **ALB to check only the Readiness probe**. This ensures that traffic is routed only to pods that are ready to serve requests.

### Application Lifecycle  

Here’s the typical lifecycle of our application running inside a Kubernetes pod:

1. **Container starts.**  
2. **Application initializes.**  
3. **Liveness probe starts returning `200 OK`** – This tells Kubernetes that the container is running.  
4. **Application runs internal health checks** and determines it is ready to handle traffic.  
5. **Readiness probe starts returning `200 OK`.**  
6. **ALB health checks pass, and the pod is added to the target group.**  
7. **Pod starts receiving traffic.**  

Now, let’s look at **what happens when a pod needs to shut down**.

### Graceful Shutdown Sequence  

1. **Kubernetes triggers the `preStop` hook.**  
2. **PreStop sends `SIGUSR1`** to the application and waits for `N` seconds.  
3. **Application handles `SIGUSR1`** by setting the Readiness probe to fail.  
4. **ALB health checks begin failing, preventing new requests from being sent.**  
5. **ALB removes the pod from the target group.**  
6. **`preStop` hook completes its wait time and returns.**  
7. **Kubernetes sends `SIGTERM` to the pod.**  
8. **Application finishes any in-flight requests and shuts down cleanly.**  

This approach ensures that the **ALB never sends traffic to a pod that is in the process of shutting down**.

## Bonus Tip: Readiness as a Scaling Signal  

Beyond startup and shutdown, the Readiness probe can also act as a **signal for auto-scaling**. If your application becomes overloaded, it can **temporarily fail the Readiness check** to indicate that it shouldn’t receive more traffic. This can serve as an additional metric for scaling decisions.

---

By aligning Kubernetes health checks with ALB behavior, we’ve been able to achieve **smoother deployments, zero-downtime updates, and more reliable scaling**. Hopefully, this saves you from some of the pitfalls we encountered along the way!
