import dns.resolver
import smtplib
import socket

def check_mx_records(domain):
    """Vérifie les enregistrements MX pour un domaine."""
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        print(f"MX records for {domain}:")
        for mx in mx_records:
            print(f" - {mx.exchange} (priority: {mx.preference})")
        return True
    except Exception as e:
        print(f"Erreur lors de la vérification des enregistrements MX: {e}")
        return False

def check_dkim_record(domain):
    """Vérifie les enregistrements DKIM pour un domaine."""
    try:
        dkim_selector = 'default'  # Remplacer par le sélecteur DKIM approprié si connu
        dkim_domain = f"{dkim_selector}._domainkey.{domain}"
        dkim_records = dns.resolver.resolve(dkim_domain, 'TXT')
        print(f"DKIM records for {domain}:")
        for record in dkim_records:
            print(f" - {record.to_text()}")
        return True
    except Exception as e:
        print(f"Erreur lors de la vérification des enregistrements DKIM: {e}")
        return False

def check_tls_support(domain):
    """Vérifie la prise en charge du chiffrement TLS sur le serveur SMTP."""
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        for mx in mx_records:
            smtp_server = str(mx.exchange)
            print(f"Checking TLS support for {smtp_server}...")
            server = smtplib.SMTP(smtp_server)
            server.starttls()
            print(f"TLS support is enabled on {smtp_server}")
            server.quit()
        return True
    except (smtplib.SMTPException, socket.gaierror) as e:
        print(f"Erreur lors de la vérification du chiffrement TLS: {e}")
        return False

def main(domain):
    print(f"Checking email configuration for domain: {domain}")
    mx_status = check_mx_records(domain)
    dkim_status = check_dkim_record(domain)
    tls_status = check_tls_support(domain)

    if all([mx_status, dkim_status, tls_status]):
        print(f"Toutes les vérifications de conformité ont réussi pour le domaine {domain}.")
    else:
        print(f"Une ou plusieurs vérifications de conformité ont échoué pour le domaine {domain}.")

if __name__ == "__main__":
    domain = input("Entrez le domaine à vérifier : ")
    main(domain)