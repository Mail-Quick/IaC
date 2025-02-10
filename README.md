
# What Is IaC(Infrastructure as Code)

IaC의 가장 중요한 가치는 Infrastructure 의 문서화라고 생각합니다.  
서비스의 인프라 스펙을 명시한 문서가 곧 HCL 언어로 구성된 .tf 파일이며, 이는 Runnable 해야 합니다.

## Target 

1. Runnable Spec 을 작성하는 것을 목표로 합니다. 
2. 인프라를 구성하는 리소스가 모두 삭제되어도 간단한 명령어 하나로 원복이 가능해야 하며 재사용성이 높아야 합니다.

## Convention 

### Module
  
1. VPC 와 같은 복합적인 서비스는 Module 의 형태로 사용하지 않습니다.
    - VPC 를 여러개 사용하는 서비스의 경우, 사용되는 모든 VPC 의 형상이 같을거라는 보장이 없다.
    - 비용을 위해서 어떤 VPC 는 AZ 1개 , 다른 VPC 는 AZ 3개..  
    - Spot Instance 를 사용하는 옵션이나 Subnet 등의 설정도 달라질 확률이 높음
    - 이를 처리하려면 Module 의 분기가 계속해서 늘어나게 됨 
2. EC2 와 같은 단일 서비스는 Module 의 형태로 사용합니다.
    - 다른 VPC, Region, 서비스에서도 형상이 같을 확률이 높음 


