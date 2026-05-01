# Week 12 - Network Design & Identity
**Autors:** Pau Cabestany i Eric Hernandez

## 1. Network Architecture Diagram
Hem dissenyat l'arquitectura utilitzant el principi de "Defense-in-Depth" (Defensa en profunditat) i segmentació de xarxes.
```mermaid
graph TD
    Internet((Internet)) -->|Port 80/443| DMZ[DMZ / External Partners]
    OfficeA[Office A] -->|VPN IPsec| InternalRouter{Internal Router}
    OfficeB[Office B] -->|VPN IPsec| InternalRouter
    
    DMZ -->|Strict Rules| Staging[Staging Environment]
    DMZ -->|Strict Rules| Prod[Production Environment]
    
    InternalRouter --> Dev[Development Environment]
    InternalRouter --> Staging
    InternalRouter --> Prod
    
    Prod --> ProdDB[(Production DB)]
    Dev -.->|BLOCKED| ProdDB
