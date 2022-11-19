"""Tasks for use with Invoke."""
from invoke import task


@task
def yamllint(context):
    """Run yamllint."""
    exec_cmd = "yamllint ."
    context.run(exec_cmd)


@task
def tests(context):
    """Run all tests for this repository."""
    print("Running yamllint")
    yamllint(context)
    print("yamllint succeeded")

    print("All tests have passed!")
