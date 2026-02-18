import os
import configparser
import sqlite3
from datetime import datetime, timedelta
import csv
from pyfortify import FortifySSC

# Configuration
CONFIG_FILE = '/config/pyfortify.cfg'
DB_FILE = '/data/fortify_stats.db'
OUTPUT_DIR = '/output'

def load_config():
    config = configparser.ConfigParser()
    config.read(CONFIG_FILE)
    return config['DEFAULT']

def connect_to_fortify():
    config = load_config()
    return FortifySSC(config['url'], token=config.get('token'), username=config.get('username'), password=config.get('password'))

def init_database():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS weekly_stats (
        week_start TEXT,
        application_name TEXT,
        critical_count INTEGER,
        high_count INTEGER,
        PRIMARY KEY (week_start, application_name)
    )
    ''')
    conn.commit()
    return conn

def get_week_dates():
    today = datetime.now().date()
    start_of_week = today - timedelta(days=today.weekday())
    end_of_week = start_of_week + timedelta(days=6)
    return start_of_week, end_of_week

def extract_statistics(fssc):
    start_of_week, end_of_week = get_week_dates()
    stats = []

    for app in fssc.applications.get_all():
        if 'master' in app.name.lower():
            critical_count = fssc.issues.get_count(
                application_id=app.id,
                start_date=start_of_week,
                end_date=end_of_week,
                filters=[
                    ('severities', ['Critical']),
                    ('analysis', ['audited', 'suppressed'])
                ]
            )
            high_count = fssc.issues.get_count(
                application_id=app.id,
                start_date=start_of_week,
                end_date=end_of_week,
                filters=[
                    ('severities', ['High']),
                    ('analysis', ['audited', 'suppressed'])
                ]
            )
            stats.append({
                'week_start': start_of_week.strftime('%Y-%m-%d'),
                'application_name': app.name,
                'critical_count': critical_count,
                'high_count': high_count
            })
    
    return stats

def update_database(conn, stats):
    cursor = conn.cursor()
    for stat in stats:
        cursor.execute('''
        INSERT OR REPLACE INTO weekly_stats
        (week_start, application_name, critical_count, high_count)
        VALUES (?, ?, ?, ?)
        ''', (stat['week_start'], stat['application_name'], stat['critical_count'], stat['high_count']))
    conn.commit()

def generate_report(conn):
    cursor = conn.cursor()
    current_week = datetime.now().date() - timedelta(days=datetime.now().weekday())
    last_week = current_week - timedelta(weeks=1)
    
    cursor.execute('''
    SELECT
        current.week_start,
        current.application_name,
        current.critical_count,
        current.high_count,
        current.critical_count - COALESCE(previous.critical_count, 0) AS critical_trend,
        current.high_count - COALESCE(previous.high_count, 0) AS high_trend
    FROM
        weekly_stats current
    LEFT JOIN
        weekly_stats previous
    ON
        current.application_name = previous.application_name
        AND previous.week_start = ?
    WHERE
        current.week_start = ?
    ''', (last_week.strftime('%Y-%m-%d'), current_week.strftime('%Y-%m-%d')))

    report_data = cursor.fetchall()
    
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    report_file = os.path.join(OUTPUT_DIR, f'fortify_report_{current_week.strftime("%Y-%m-%d")}.csv')
    
    with open(report_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Semaine', 'Application', 'Vulnérabilités critiques', 'Vulnérabilités hautes', 'Tendance critiques', 'Tendance hautes'])
        for row in report_data:
            writer.writerow(row)

def run_analysis():
    fssc = connect_to_fortify()
    conn = init_database()
    stats = extract_statistics(fssc)
    update_database(conn, stats)
    generate_report(conn)
    conn.close()

if __name__ == "__main__":
    run_analysis()