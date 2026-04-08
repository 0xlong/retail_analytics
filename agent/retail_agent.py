import anthropic
import duckdb
from prompts import SYSTEM_SQL, SYSTEM_NARRATE

DB = duckdb.connect("retail.duckdb", read_only=True)
CLAUDE = anthropic.Anthropic()


def ask(question: str) -> str:
    # Step 1: Convert question to SQL
    sql_response = CLAUDE.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=500,
        system=SYSTEM_SQL,
        messages=[{"role": "user", "content": question}],
    )
    sql = sql_response.content[0].text.strip()

    # Step 2: Run SQL on DuckDB
    results = DB.execute(sql).fetchdf()

    # Step 3: Narrate the results in plain English
    narration = CLAUDE.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=300,
        system=SYSTEM_NARRATE,
        messages=[{
            "role": "user",
            "content": (
                f"Question: {question}\n"
                f"SQL: {sql}\n"
                f"Results:\n{results.to_string()}"
            ),
        }],
    )
    return narration.content[0].text


if __name__ == "__main__":
    questions = [
        "Which 5 countries have the deepest average discounting?",
        "What's the gender split in the Running category across all markets?",
        "Which markets have the worst out-of-stock rates?",
    ]
    for q in questions:
        print(f"\nQ: {q}")
        print(ask(q))
        print("-" * 60)
