*This project has been created as part of the 42 curriculum by k123.*

# Inception

## Description
Inception is a System Administration related project. The goal is to set up a small infrastructure composed of specific services (NGINX, WordPress, MariaDB) using **Docker**. Each service runs in a dedicated container, built from custom Dockerfiles, and orchestrated using **Docker Compose**.

## Instructions
### Prerequisites
- Docker Engine & Docker Compose
- `make`

### Installation & Execution
1. **Clone the repository**:
   ```bash
   git clone <repo_url> inception
   cd inception
   ```
2. **Setup Host**:
   Add the following line to your `/etc/hosts` file (requires sudo):
   ```
   127.0.0.1 k123.42.fr
   ```
3. **Run**:
   ```bash
   make
   ```
   This will build the images and start the containers. Docker secrets are handled automatically.

4. **Access**:
   - Website: [https://k123.42.fr](https://k123.42.fr)
   - Admin Login: `https://k123.42.fr/wp-admin`

## Project Description & Design Choices

### Docker & Sources
We strictly follow the rule of "one container per service".
1. **NGINX**: The entry point. Handles TLS termination (port 443) and forwards PHP requests to the WordPress container.
2. **WordPress**: Runs PHP-FPM. Does *not* contain NGINX. Connects to MariaDB for data.
3. **MariaDB**: The database backend. Stores WordPress data.

### Technical Comparisons

#### Virtual Machines vs Docker
| Feature | Virtual Machine (VM) | Docker Container |
|:--- |:--- |:--- |
| **Isolation** | Hardware-level (Heavy) | OS-level (Lightweight) |
| **OS** | Full Guest OS required | Shares Host Kernel |
| **Startup** | Minutes (Boot sequence) | Milliseconds/Seconds |
| **Size** | GBs | MBs |

*Choice*: Docker is used here for efficiency, portability, and rapid deployment.

#### Secrets vs Environment Variables
| Feature | Environment Variables | Docker Secrets |
|:--- |:--- |:--- |
| **Security** | Low. Visible in `docker inspect` | High. Encrypted at rest/transit (Swarm) or tmpfs (Compose) |
| **Storage** | Plain text in shell/files | Files mounted in `/run/secrets` |
| **Usage** | config flags, simple setup | Sensitive data (passwords, keys) |

*Choice*: We use **Secrets** for passwords to prevent them from leaking in container logs or inspection.

#### Docker Network vs Host Network
| Feature | Docker Network (Bridge) | Host Network |
|:--- |:--- |:--- |
| **Isolation** | High. Dedicated network namespace | None. Shares host network stack |
| **Port Mapping** | Explicit (`-p 80:80`). Secure. | Direct access to host ports |
| **Communication** | DNS resolution by container name | `localhost` (confusing if multiple services) |

*Choice*: We use a custom **Bridge Network** (`inception`) to allow containers to talk to each other by name (`wordpress` talks to `mariadb`) without exposing everything to the host.

#### Docker Volumes vs Bind Mounts
| Feature | Docker Volumes | Bind Mounts |
|:--- |:--- |:--- |
| **Management** | Managed by Docker (`/var/lib/docker/...`) | Managed by User (Host path) |
| **Portability** | High. independent of host folder structure | Low. Relies on specific host paths |
| **Performance** | Native | Native (but permission issues common) |

*Choice*: We use **Bind Mounts** for explicit visibility of data on the host (`~/data/...`) as required by the subject, giving the user direct access to the files.

## Resources
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### AI Usage
This project utilized **Google Gemini** (Antigravity) to:
- Generate the directory structure and initial Dockerfiles.
- Refine the `Makefile` logic for directory creation.
- Ensure strict adherence to the subject (e.g., checking for forbidden patterns like `tail -f`).
